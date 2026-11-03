"""Run every Postgres gold query and check it against the original SQLite gold.

Any query that errors, times out, returns no rows, or returns a different
result set than the SQLite gold on the SQLite database ("mismatch") is
listed in gold_review.csv for review.

Output:
  data/processed/gold_check.jsonl   one line per question
  data/processed/gold_review.csv    only the suspicious ones
"""
import csv
import json
import shutil
import sqlite3
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path

import psycopg

from common import BIRD_TZ, load_questions, questions_file, same_result

ROOT = Path(__file__).resolve().parent.parent
PROC = ROOT / "data" / "processed"
TIMEOUT_MS = 30_000
SQLITE_TIMEOUT_S = 60  # SQLite has no statement timeout, so we abort from a progress handler
def local_copy(path):
    # SQLite over /mnt/c is very slow from WSL, so query a copy on the Linux disk
    dst = Path.home() / ".cache" / "nplusonebench" / path.name
    if not dst.exists() or dst.stat().st_size != path.stat().st_size:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, dst)
    return dst


def sqlite_gold():
    raw = ROOT / "data" / "raw"
    qf = sorted(raw.rglob("mini_dev_sqlite.json"))
    dbs = {f.stem: f for f in raw.rglob("dev_databases/*/*.sqlite")}
    if not qf:
        return {}, dbs
    return {q["question_id"]: q["SQL"] for q in json.loads(qf[0].read_text())}, dbs


def main(dsn="dbname=bird"):
    questions = load_questions()
    print(f"Loaded {len(questions)} questions from {questions_file().relative_to(ROOT)}")

    sq_sql, sq_dbs = sqlite_gold()
    sq_conns = {}

    PROC.mkdir(parents=True, exist_ok=True)
    results = []
    with psycopg.connect(dsn, autocommit=True) as conn:
        conn.execute(f"SET statement_timeout = {TIMEOUT_MS}")
        conn.execute(f"SET TIME ZONE '{BIRD_TZ}'")
        for i, q in enumerate(questions):
            rec = {
                "question_id": q.get("question_id", i),
                "db_id": q["db_id"],
                "difficulty": q.get("difficulty", "unknown"),
                "question": q["question"],
                "evidence": q.get("evidence", ""),
                "sql": q["SQL"],
                "gold_fixed": q.get("gold_fixed", False),
            }
            t0 = time.perf_counter()
            rows = None
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

            # Cross-check against the original SQLite gold answer.
            qid = rec["question_id"]
            if rows is not None and qid in sq_sql and q["db_id"] in sq_dbs:
                if q["db_id"] not in sq_conns:
                    sq_conns[q["db_id"]] = sqlite3.connect(local_copy(sq_dbs[q["db_id"]]))
                sq = sq_conns[q["db_id"]]
                deadline = time.monotonic() + SQLITE_TIMEOUT_S
                sq.set_progress_handler(lambda: time.monotonic() > deadline, 100_000)
                try:
                    sq_rows = sq.execute(sq_sql[qid]).fetchall()
                    rec["sqlite_match"] = same_result(rows, sq_rows)
                    rec["sqlite_n_rows"] = len(sq_rows)
                    if not rec["sqlite_match"]:
                        rec["sqlite_preview"] = [list(map(str, r)) for r in sq_rows[:3]]
                        if rec["status"] == "ok":
                            rec["status"] = "mismatch"
                except sqlite3.Error as e:
                    rec["sqlite_match"] = None
                    rec["sqlite_error"] = "timeout" if time.monotonic() > deadline else str(e)
            results.append(rec)
            if (i + 1) % 50 == 0:
                print(f"  {i + 1}/{len(questions)}")

    with open(PROC / "gold_check.jsonl", "w") as f:
        for r in results:
            f.write(json.dumps(r) + "\n")

    suspicious = [r for r in results if r["status"] != "ok"]
    with open(PROC / "gold_review.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["question_id", "db_id", "difficulty", "status", "error", "question", "sql",
                    "pg_rows", "sqlite_rows", "pg_preview", "sqlite_preview", "verdict", "note"])
        for r in suspicious:
            w.writerow([r["question_id"], r["db_id"], r["difficulty"], r["status"],
                        r.get("error", ""), r["question"], r["sql"], r.get("n_rows"),
                        r.get("sqlite_n_rows"), json.dumps(r.get("preview")),
                        json.dumps(r.get("sqlite_preview")), "", ""])

    print("\nStatus:", dict(Counter(r["status"] for r in results)))
    print("By difficulty:", dict(Counter(r["difficulty"] for r in results)))
    per_db = defaultdict(Counter)
    for r in results:
        per_db[r["db_id"]][r["status"]] += 1
    cols = ("ok", "mismatch", "empty", "error", "timeout")
    print(f"\n{'database':28} " + "  ".join(f"{s:>8}" for s in cols))
    for db_id in sorted(per_db):
        c = per_db[db_id]
        print(f"{db_id:28} " + "  ".join(f"{c[s]:>8}" for s in cols))
    print(f"\n{len(suspicious)} queries to review by hand -> data/processed/gold_review.csv")


if __name__ == "__main__":
    main(*sys.argv[1:])
