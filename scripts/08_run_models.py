"""Ask a model for SQL and ActiveRecord answers to every question.

    python scripts/08_run_models.py qwen2.5-coder-3b [--limit 20] [--kind sql|ar|ar_retry]

Talks to any OpenAI-compatible endpoint (Ollama, Groq, Gemini...), listed in
config/models.json. Temperature 0. Every response is cached under
data/runs/<model>/, so a rerun only asks for what's missing.

ar_retry is the feedback step: answers the harness flagged as N+1 go back to
the model with the repeated query, once.
"""
import argparse
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from common import ROOT, load_questions

RUNS = ROOT / "data" / "runs"
RESULTS = ROOT / "data" / "results"
SCHEMA = json.loads((ROOT / "data" / "processed" / "schema.json").read_text())["databases"]
MODELS_DIR = ROOT / "harness" / "models"

SQL_SYSTEM = (
    "You are an expert in PostgreSQL. Answer the question with a single SQL query. "
    "Reply with the query in a ```sql code block and nothing else."
)
AR_SYSTEM = (
    "You are an expert Ruby on Rails developer. The ActiveRecord models below are loaded "
    "and connected to the database. Answer the question with ActiveRecord code. "
    "The value of the last expression is the answer: return plain values (a number, a string, "
    "or an array with one array per result row), not model objects. "
    "Reply with the code in a ```ruby code block and nothing else."
)
RETRY_NOTE = (
    "Your code ran {n} queries. This query ran {k} times:\n\n{sql}\n\n"
    "Rewrite it so it doesn't run a query per row. Same rules as before."
)


def quote(name):
    return name if re.fullmatch(r"[a-z_][a-z0-9_]*", name) else '"' + name.replace('"', '""') + '"'


def create_tables(db_id):
    out = []
    for table, info in SCHEMA[db_id].items():
        cols = [f"  {quote(c['name'])} {c['type']}{'' if c['nullable'] else ' NOT NULL'}" for c in info["columns"]]
        pk = info["pg_primary_key"] or [c.lower() for c in info["sqlite_pk"]]
        if pk:
            cols.append(f"  PRIMARY KEY ({', '.join(map(quote, pk))})")
        by_lower = {c["name"].lower(): c["name"] for c in info["columns"]}
        for fk in info["foreign_keys"]:
            ref_cols = {c["name"].lower(): c["name"] for c in SCHEMA[db_id][fk["ref_table_pg"]]["columns"]}
            ref = ref_cols.get((fk["ref_column"] or "").lower())
            target = f"{quote(fk['ref_table_pg'])}({quote(ref)})" if ref else quote(fk["ref_table_pg"])
            line = f"  FOREIGN KEY ({quote(by_lower[fk['column'].lower()])}) REFERENCES {target}"
            if line not in cols:
                cols.append(line)
        out.append(f"CREATE TABLE {quote(table)} (\n" + ",\n".join(cols) + "\n);")
    return "\n\n".join(out)


def model_files(db_id):
    return "\n".join(p.read_text() for p in sorted((MODELS_DIR / db_id).glob("*.rb")))


def ask_text(q):
    hint = f"\nHint: {q['evidence']}" if q.get("evidence") else ""
    return f"Question: {q['question']}{hint}"


def build_messages(kind, q, retry=None):
    if kind == "sql":
        return [{"role": "system", "content": SQL_SYSTEM},
                {"role": "user", "content": f"Database schema:\n\n{create_tables(q['db_id'])}\n\n{ask_text(q)}"}]
    msgs = [{"role": "system", "content": AR_SYSTEM},
            {"role": "user", "content": f"Models:\n\n{model_files(q['db_id'])}\n{ask_text(q)}"}]
    if retry:
        sql, k = retry["repeated"]
        msgs += [{"role": "assistant", "content": f"```ruby\n{retry['ruby']}\n```"},
                 {"role": "user", "content": RETRY_NOTE.format(n=retry["query_count"], k=k, sql=sql)}]
    return msgs


def extract_code(text, lang):
    blocks = re.findall(r"```([a-zA-Z]*)\n(.*?)```", text, re.S)
    for tag, body in reversed(blocks):
        if tag.lower() in (lang, "rb" if lang == "ruby" else "postgresql"):
            return body.strip()
    if blocks:
        return blocks[-1][1].strip()
    return text.strip()


def chat(cfg, messages, retries=6):
    """Returns (text, usage)."""
    if cfg["provider"] == "ollama":
        # native API, because the OpenAI-style one can't raise the 4k default context
        host = os.environ.get("OLLAMA_HOST") or cfg["base_url"].removesuffix("/v1")
        url = host.rstrip("/") + "/api/chat"
        body = {"model": cfg["model"], "messages": messages, "stream": False,
                "options": {"temperature": 0, "seed": 0, "num_ctx": 8192}}
        resp = post(url, body, {"Content-Type": "application/json"}, retries)
        return resp["message"]["content"], {"prompt_tokens": resp.get("prompt_eval_count"),
                                            "completion_tokens": resp.get("eval_count")}
    headers = {"Content-Type": "application/json"}
    if cfg.get("key_env"):
        key = os.environ.get(cfg["key_env"])
        if not key:
            sys.exit(f"Set {cfg['key_env']} to use {cfg['id']}")
        headers["Authorization"] = f"Bearer {key}"
    body = {"model": cfg["model"], "messages": messages, "temperature": 0, "seed": 0}
    resp = post(cfg["base_url"].rstrip("/") + "/chat/completions", body, headers, retries)
    return resp["choices"][0]["message"]["content"] or "", resp.get("usage")


def post(url, body, headers, retries):
    req = urllib.request.Request(url, json.dumps(body).encode(), headers)
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=600) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503) and attempt < retries - 1:
                wait = int(e.headers.get("Retry-After") or 0) or 2 ** attempt * 5
                print(f"  {e.code}, waiting {wait}s")
                time.sleep(wait)
                continue
            raise


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("model")
    ap.add_argument("--kind", choices=["sql", "ar", "ar_retry", "both"], default="both")
    ap.add_argument("--limit", type=int)
    ap.add_argument("--db")
    args = ap.parse_args()

    configs = {m["id"]: m for m in json.loads((ROOT / "config" / "models.json").read_text())}
    cfg = configs.get(args.model) or sys.exit(f"unknown model {args.model}; see config/models.json")
    out_dir = RUNS / cfg["id"]
    out_dir.mkdir(parents=True, exist_ok=True)

    questions = [q for q in load_questions() if not args.db or q["db_id"] == args.db]
    questions = questions[: args.limit] if args.limit else questions
    kinds = ["sql", "ar"] if args.kind == "both" else [args.kind]

    retry_info = {}
    if "ar_retry" in kinds:
        res = RESULTS / f"{cfg['id']}.jsonl"
        for line in res.read_text().splitlines() if res.exists() else []:
            r = json.loads(line)
            if r.get("n_plus_one") and r.get("repeated"):
                sql, k = max(r["repeated"].items(), key=lambda kv: kv[1])
                retry_info[r["question_id"]] = {"ruby": r["ruby"], "query_count": r["query_count"], "repeated": (sql, k)}
        questions = [q for q in questions if q["question_id"] in retry_info]
        print(f"{len(questions)} N+1 answers to retry")

    done = 0
    for kind in kinds:
        lang = "sql" if kind == "sql" else "ruby"
        for q in questions:
            path = out_dir / f"{q['question_id']}.{kind}.json"
            messages = build_messages(kind, q, retry_info.get(q["question_id"]))
            prompt_hash = hashlib.sha256(json.dumps(messages).encode()).hexdigest()[:16]
            if path.exists() and json.loads(path.read_text()).get("prompt_hash") == prompt_hash:
                continue
            t0 = time.time()
            text, usage = chat(cfg, messages)
            path.write_text(json.dumps({
                "question_id": q["question_id"], "kind": kind, "model": cfg["model"],
                "prompt_hash": prompt_hash, "seconds": round(time.time() - t0, 1),
                "usage": usage, "response": text, "code": extract_code(text, lang),
            }, indent=1))
            done += 1
            print(f"  {kind} #{q['question_id']} ({time.time() - t0:.1f}s)")
    print(f"{done} new responses in {out_dir.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
