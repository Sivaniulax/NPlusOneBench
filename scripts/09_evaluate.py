"""Run a model's cached answers and score them against the gold SQL.

    python scripts/09_evaluate.py qwen2.5-coder-3b

SQL answers run in Postgres (read-only, 30 s timeout). ActiveRecord answers
run through harness/run.rb, one Ruby process per database. Both result sets
are compared with gold the same way 04_check_gold.py compares Postgres and
SQLite.

Output: data/results/<model>.jsonl, one line per question.
"""
import json
import os
import re
import subprocess
import sys
import time
from collections import defaultdict

import psycopg

from common import BIRD_TZ, ROOT, load_questions, same_result

RUNS = ROOT / "data" / "runs"
RESULTS = ROOT / "data" / "results"
TIMEOUT_MS = 30_000

# Whole query handed to the database as a string
RAW_SQL = re.compile(r"find_by_sql|connection\.(execute|exec_query|select_all|select_rows|select_values?|select_one)|Arel\.sql")
# SQL text inside an ActiveRecord call: .select("SUM(...)"), .where("a > ?"), .joins("INNER JOIN ...")
SQL_FRAGMENT = re.compile(r"\.(select|where|having|joins|group|order|pluck|calculate|from)\(\s*['\"%]")


def pg_conn():
    conn = psycopg.connect("dbname=bird", autocommit=True)
    conn.execute(f"SET statement_timeout = {TIMEOUT_MS}")
    conn.execute(f"SET TIME ZONE '{BIRD_TZ}'")
    conn.execute("SET default_transaction_read_only = on")
    return conn


def run_sql(conn, sql):
    t0 = time.perf_counter()
    try:
        rows = conn.execute(sql).fetchall()
        return {"rows": rows, "ms": round((time.perf_counter() - t0) * 1000, 1)}
    except psycopg.errors.QueryCanceled:
        return {"error": "Timeout"}
    except psycopg.Error as e:
        return {"error": f"{type(e).__name__}: {str(e).splitlines()[0]}"}


def run_ruby(db_id, tasks):
    env = dict(os.environ, BUNDLE_GEMFILE=str(ROOT / "harness" / "Gemfile"))
    proc = subprocess.run(
        ["bundle", "exec", "ruby", str(ROOT / "harness" / "run.rb"), db_id],
        input="".join(json.dumps(t) + "\n" for t in tasks),
        capture_output=True, text=True, env=env, timeout=3600,
    )
    if proc.returncode != 0 and not proc.stdout:
        sys.exit(f"harness failed for {db_id}:\n{proc.stderr[-2000:]}")
    return {r["id"]: r for r in map(json.loads, proc.stdout.splitlines())}


def cached(model_id, qid, kind):
    p = RUNS / model_id / f"{qid}.{kind}.json"
    return json.loads(p.read_text()) if p.exists() else None


def main():
    model_id = sys.argv[1]
    if not (RUNS / model_id).exists():
        sys.exit(f"no runs for {model_id}; run scripts/08_run_models.py first")
    questions = {q["question_id"]: q for q in load_questions()}
    conn = pg_conn()

    gold = {}
    for qid, q in questions.items():
        g = run_sql(conn, q["SQL"])
        gold[qid] = g.get("rows")

    results = {}
    for qid, q in questions.items():
        sql = cached(model_id, qid, "sql")
        ar = cached(model_id, qid, "ar")
        if not sql and not ar:
            continue
        rec = {"question_id": qid, "db_id": q["db_id"], "difficulty": q["difficulty"],
               "sql": sql and sql["code"], "ruby": ar and ar["code"]}
        if sql:
            r = run_sql(conn, sql["code"])
            rec["sql_error"] = r.get("error")
            rec["sql_ms"] = r.get("ms")
            rec["sql_correct"] = "rows" in r and gold[qid] is not None and same_result(r["rows"], gold[qid])
        results[qid] = rec

    # ActiveRecord answers (and N+1 retries), grouped by database
    for kind in ("ar", "ar_retry"):
        by_db = defaultdict(list)
        for qid, rec in results.items():
            c = cached(model_id, qid, kind)
            if c:
                by_db[rec["db_id"]].append({"id": qid, "code": c["code"]})
        for db_id, tasks in sorted(by_db.items()):
            print(f"  {kind} {db_id}: {len(tasks)} answers")
            for qid, out in run_ruby(db_id, tasks).items():
                rec = results[qid]
                correct = "rows" in out and gold[qid] is not None and same_result(out["rows"], gold[qid])
                prefix = "" if kind == "ar" else "retry_"
                rec[f"{prefix}ar_correct"] = correct
                rec[f"{prefix}ar_error"] = out.get("error")
                rec[f"{prefix}query_count"] = out["query_count"]
                rec[f"{prefix}rows_loaded"] = out["rows_loaded"]
                rec[f"{prefix}n_plus_one"] = out["n_plus_one"]
                if kind == "ar":
                    rec["ar_ms"] = out["ms"]
                    rec["repeated"] = out["repeated"]
                    rec["queries"] = out["queries"]
                    rec["gold_rows"] = len(gold[qid] or [])
                else:
                    rec["retry_ruby"] = cached(model_id, qid, kind)["code"]

    for rec in results.values():
        code = rec.get("ruby") or ""
        rec["sql_fallback"] = bool(RAW_SQL.search(code))
        rec["sql_fragment"] = bool(SQL_FRAGMENT.search(code))

    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / f"{model_id}.jsonl"
    with open(out, "w") as f:
        for qid in sorted(results):
            f.write(json.dumps(results[qid], default=str) + "\n")

    rs = list(results.values())
    n = len(rs)
    pct = lambda key: f"{100 * sum(bool(r.get(key)) for r in rs) / n:.1f}%"
    print(f"\n{model_id}: {n} questions")
    print(f"  SQL correct {pct('sql_correct')}, ActiveRecord correct {pct('ar_correct')}, "
          f"N+1 {pct('n_plus_one')}, raw SQL fallback {pct('sql_fallback')}")
    print(f"Wrote {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
