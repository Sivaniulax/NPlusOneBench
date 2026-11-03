"""Shared bits: loading questions and comparing result sets."""
import datetime as dt
import decimal
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
BIRD_TZ = "Asia/Shanghai"  # zone the dump was taken in; see 02_load_postgres.sh
GOLD_FIXES = ROOT / "data" / "gold_fixes.json"
TS_TEXT = re.compile(r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.0+)?$")


def questions_file():
    for pattern in ("mini_dev_postgresql.json", "mini_dev_pg*.json", "*postgres*.json"):
        hits = sorted(RAW.rglob(pattern))
        if hits:
            return hits[0]
    raise SystemExit("Mini-Dev Postgres questions not found - run scripts/01_download.sh first")


def load_questions(fixed=True):
    """Unique Mini-Dev questions, with our hand fixes to the Postgres gold SQL applied."""
    questions, seen = [], set()
    for q in json.loads(questions_file().read_text()):
        # 137 and 138 appear twice in Mini-Dev, word for word
        if q["question_id"] not in seen:
            seen.add(q["question_id"])
            questions.append(q)
    if fixed and GOLD_FIXES.exists():
        fixes = {int(k): v for k, v in json.loads(GOLD_FIXES.read_text()).items()}
        for q in questions:
            if q["question_id"] in fixes:
                q["SQL"] = fixes[q["question_id"]]["sql"]
                q["gold_fixed"] = True
    return questions


def norm(v):
    """Make a cell from Postgres, SQLite or the Ruby harness comparable."""
    if v is None:
        return None
    if isinstance(v, bool):
        return int(v)
    if isinstance(v, (int, float, decimal.Decimal)):
        return round(float(v), 4)
    if isinstance(v, dt.datetime):
        return v.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(v, dt.date):
        return v.isoformat()
    if isinstance(v, str) and TS_TEXT.match(v):
        return v.split(".")[0]
    return v


def result_set(rows):
    return {tuple(norm(c) for c in r) for r in rows}


def cell_eq(a, b):
    # some Postgres columns are real (float4) where SQLite keeps doubles
    if isinstance(a, float) and isinstance(b, float):
        return math.isclose(a, b, rel_tol=1e-4, abs_tol=1e-6)
    return a == b


def same_result(rows_a, rows_b):
    """Set comparison like BIRD's own evaluation, with a float tolerance."""
    a, b = result_set(rows_a), result_set(rows_b)
    if a == b:
        return True
    if len(a) != len(b) or len(a) > 2000:
        return False
    rest = list(b)
    for row in a:
        hit = next((r for r in rest if len(r) == len(row) and all(map(cell_eq, row, r))), None)
        if hit is None:
            return False
        rest.remove(hit)
    return True
