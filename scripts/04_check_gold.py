"""Run every gold PostgreSQL query in Mini-Dev and record what happens.

This is the first pass of the "hand-check gold-label noise" step: any gold
query that errors, times out, or returns 0 rows goes on a list to review by
hand before it is allowed into the benchmark.

Output:
  data/processed/gold_check.jsonl   one line per question
  data/processed/gold_review.csv    only the suspicious ones
"""
import csv
import json
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path

import psycopg

ROOT = Path(__file__).resolve().parent.parent
PROC = ROOT / "data" / "processed"
TIMEOUT_MS = 30_000


def find_questions():
    raw = ROOT / "data" / "raw"
    for pattern in ("mini_dev_postgresql.json", "mini_dev_pg*.json", "*postgres*.json"):
        hits = sorted(raw.rglob(pattern))
        if hits:
            return hits[0]
    sys.exit("PostgreSQL question file not found under data/raw - run scripts/01_download.sh")


def main(dsn="dbname=bird"):
    qfile = find_questions()
    questions = json.loads(qfile.read_text())
    print(f"Loaded {len(questions)} questions from {qfile.relative_to(ROOT)}")

    PROC.mkdir(parents=True, exist_ok=True)
    results = []
    with psycopg.connect(dsn, autocommit=True) as conn:
        conn.execute(f"SET statement_timeout = {TIMEOUT_MS}")
        for i, q in enumerate(questions):
            rec = {
                "question_id": q.get("question_id", i),
                "db_id": q["db_id"],
                "difficulty": q.get("difficulty", "unknown"),
                "question": q["question"],
                "evidence": q.get("evidence", ""),
                "sql": q["SQL"],
            }
            t0 = time.perf_counter()
            try:
                rows = conn.execute(q["SQL"]).fetchall()
                rec.update(status="ok", n_rows=len(rows), preview=[list(map(str, r)) for r in rows[:3]])
            except psycopg.errors.QueryCanceled:
                rec.update(status="timeout", n_rows=None)
            except psycopg.Error as e:
                rec.update(status="error", n_rows=None, error=str(e).splitlines()[0])
            rec["ms"] = round((time.perf_counter() - t0) * 1000, 1)
            if rec["status"] == "ok" and rec["n_rows"] == 0:
                rec["status"] = "empty"
            results.append(rec)
            if (i + 1) % 50 == 0:
                print(f"  {i + 1}/{len(questions)}")

    with open(PROC / "gold_check.jsonl", "w") as f:
        for r in results:
            f.write(json.dumps(r) + "\n")

    suspicious = [r for r in results if r["status"] != "ok"]
    with open(PROC / "gold_review.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["question_id", "db_id", "difficulty", "status", "error", "question", "sql", "verdict", "note"])
        for r in suspicious:
            w.writerow([r["question_id"], r["db_id"], r["difficulty"], r["status"],
                        r.get("error", ""), r["question"], r["sql"], "", ""])

    print("\nStatus:", dict(Counter(r["status"] for r in results)))
    print("By difficulty:", dict(Counter(r["difficulty"] for r in results)))
    per_db = defaultdict(Counter)
    for r in results:
        per_db[r["db_id"]][r["status"]] += 1
    print(f"\n{'database':28} " + "  ".join(f"{s:>7}" for s in ("ok", "empty", "error", "timeout")))
    for db_id in sorted(per_db):
        c = per_db[db_id]
        print(f"{db_id:28} " + "  ".join(f"{c[s]:>7}" for s in ("ok", "empty", "error", "timeout")))
    print(f"\n{len(suspicious)} queries to review by hand -> data/processed/gold_review.csv")


if __name__ == "__main__":
    main(*sys.argv[1:])
