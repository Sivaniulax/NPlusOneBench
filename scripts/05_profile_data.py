"""Profile the Mini-Dev questions and databases (stdlib only, no Postgres needed).

Counts difficulty / database splits, which SQL features the gold queries use,
and per-database table, FK and row counts from the SQLite originals.
These are the numbers quoted in README and docs/journal.md.

Output: data/processed/data_profile.json
"""
import json
import re
import sqlite3
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "processed" / "data_profile.json"

FEATURES = {
    "join": r"\bJOIN\b",
    "multi_join": None,  # computed: 2+ joins
    "subquery": None,    # computed: 2+ SELECTs
    "aggregate": r"\b(COUNT|SUM|AVG|MIN|MAX)\s*\(",
    "group_by": r"\bGROUP\s+BY\b",
    "distinct": r"\bDISTINCT\b",
    "case_when": r"\bCASE\b",
    "cast": r"\bCAST\s*\(",
    "limit": r"\bLIMIT\b",
    "window": r"\bOVER\s*\(",
}


def sql_features(q):
    u = q.upper()
    f = {k: bool(re.search(p, u)) for k, p in FEATURES.items() if p}
    joins = len(re.findall(r"\bJOIN\b", u))
    f["multi_join"] = joins >= 2
    f["subquery"] = len(re.findall(r"\bSELECT\b", u)) >= 2
    return f, joins


def main():
    qfiles = sorted(RAW.rglob("mini_dev_postgresql.json"))
    if not qfiles:
        sys.exit("mini_dev_postgresql.json not found - run scripts/01_download.sh first")
    questions = json.loads(qfiles[0].read_text())

    feats, joins_by_diff = Counter(), defaultdict(list)
    for q in questions:
        f, joins = sql_features(q["SQL"])
        feats.update(k for k, v in f.items() if v)
        joins_by_diff[q["difficulty"]].append(joins)
    n = len(questions)

    dbs = {}
    for f in sorted(RAW.rglob("dev_databases/*/*.sqlite")):
        db = sqlite3.connect(f)
        tables = [r[0] for r in db.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")]
        rows = {t: db.execute(f'SELECT count(*) FROM "{t}"').fetchone()[0] for t in tables}
        fks = sum(len(db.execute(f'PRAGMA foreign_key_list("{t}")').fetchall()) for t in tables)
        no_pk = [t for t in tables if not any(r[5] for r in db.execute(f'PRAGMA table_info("{t}")'))]
        biggest = max(rows, key=rows.get)
        dbs[f.stem] = {"tables": len(tables), "foreign_keys": fks, "rows": sum(rows.values()),
                       "biggest_table": biggest, "biggest_rows": rows[biggest], "tables_without_pk": no_pk}
        db.close()

    profile = {
        "questions": n,
        "with_evidence": sum(bool(q.get("evidence")) for q in questions),
        "difficulty": dict(Counter(q["difficulty"] for q in questions)),
        "per_database": dict(Counter(q["db_id"] for q in questions).most_common()),
        "sql_feature_pct": {k: round(100 * feats[k] / n, 1) for k in
                            ["join", "multi_join", "aggregate", "cast", "limit", "case_when",
                             "distinct", "subquery", "group_by", "window"]},
        "avg_joins_by_difficulty": {k: round(sum(v) / len(v), 2) for k, v in joins_by_diff.items()},
        "databases": dbs,
        "totals": {"foreign_keys": sum(d["foreign_keys"] for d in dbs.values()),
                   "rows": sum(d["rows"] for d in dbs.values())},
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(profile, indent=2))
    print(json.dumps({k: profile[k] for k in ["questions", "difficulty", "sql_feature_pct",
                                              "avg_joins_by_difficulty", "totals"]}, indent=2))
    print(f"Wrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
