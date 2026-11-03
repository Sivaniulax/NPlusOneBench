"""Summarise every evaluated model and write the site's result files.

    python scripts/10_analyze.py

Reads data/results/*.jsonl. Writes data/results/summary.json and
taxonomy.json, and copies what the site needs into web/public/data/
(models.json, summary.json, taxonomy.json, runs/<model>.json).
"""
import datetime
import json
import random
import statistics
from collections import Counter, defaultdict

from common import ROOT

RESULTS = ROOT / "data" / "results"
SITE = ROOT / "web" / "public" / "data"
DIFFICULTIES = ["simple", "moderate", "challenging"]
BOOTSTRAP = 2000
OVERFETCH_ROWS = 1000  # loads this many records and 10x what the answer needs

random.seed(0)


def bootstrap(values):
    """Mean and 95% percentile interval."""
    if not values:
        return None
    n = len(values)
    means = sorted(sum(random.choices(values, k=n)) / n for _ in range(BOOTSTRAP))
    return {"mean": round(sum(values) / n, 4), "lo": round(means[int(0.025 * BOOTSTRAP)], 4),
            "hi": round(means[int(0.975 * BOOTSTRAP)], 4), "n": n}


def overfetch(r):
    return (r.get("rows_loaded") or 0) >= OVERFETCH_ROWS and r["rows_loaded"] > 10 * max(r.get("gold_rows") or 1, 1)


def ar_failure(r):
    """One label per wrong ActiveRecord answer."""
    err = r.get("ar_error") or ""
    if r.get("ruby") is None:
        return "no answer"
    if err.startswith(("SyntaxError", "ScriptError")):
        return "syntax error"
    if err == "Timeout" or "QueryCanceled" in err or "statement timeout" in err:
        return "timeout"
    if err.startswith("ActiveRecord::AssociationNotFoundError") or "association named" in err \
            or err.startswith("ActiveRecord::ConfigurationError"):
        return "wrong association"
    if err.startswith(("NoMethodError", "NameError", "ActiveModel::UnknownAttributeError")):
        return "unknown method or attribute"
    if err.startswith("ActiveRecord::StatementInvalid"):
        return "invalid SQL generated"
    if err:
        return "other error"
    return "wrong result"


def sql_failure(r):
    err = r.get("sql_error") or ""
    if r.get("sql") is None:
        return "no answer"
    if err == "Timeout":
        return "timeout"
    if "UndefinedColumn" in err or "UndefinedTable" in err:
        return "unknown table or column"
    if "SyntaxError" in err:
        return "syntax error"
    if err:
        return "other error"
    return "wrong result"


def summarize(rows):
    pick = lambda key: [float(bool(r.get(key))) for r in rows]
    paired = [float(bool(r.get("ar_correct"))) - float(bool(r.get("sql_correct"))) for r in rows]
    qc = [r["query_count"] for r in rows if r.get("query_count") is not None]
    out = {
        "n": len(rows),
        "sql_correct": bootstrap(pick("sql_correct")),
        "ar_correct": bootstrap(pick("ar_correct")),
        "ar_minus_sql": bootstrap(paired),
        "n_plus_one": bootstrap(pick("n_plus_one")),
        "overfetch": bootstrap([float(overfetch(r)) for r in rows]),
        "sql_fallback": bootstrap(pick("sql_fallback")),
        "sql_fragment": bootstrap(pick("sql_fragment")),
        "median_queries": statistics.median(qc) if qc else None,
        "max_queries": max(qc) if qc else None,
    }
    retried = [r for r in rows if "retry_n_plus_one" in r]
    if retried:
        out["retry"] = {
            "n": len(retried),
            "fixed_n_plus_one": sum(not r["retry_n_plus_one"] for r in retried),
            "still_correct": sum(bool(r["retry_ar_correct"]) for r in retried if r.get("ar_correct")),
            "was_correct": sum(bool(r.get("ar_correct")) for r in retried),
        }
    return out


def main():
    files = sorted(p for p in RESULTS.glob("*.jsonl") if not p.stem.startswith("_"))
    if not files:
        raise SystemExit("no results yet; run scripts/09_evaluate.py first")
    configs = {m["id"]: m for m in json.loads((ROOT / "config" / "models.json").read_text())}

    summary, taxonomy, models = {}, {}, []
    (SITE / "runs").mkdir(parents=True, exist_ok=True)
    for f in files:
        mid = f.stem
        rows = [json.loads(l) for l in f.read_text().splitlines() if l]
        by_diff = defaultdict(list)
        for r in rows:
            by_diff[r["difficulty"]].append(r)
        summary[mid] = {"all": summarize(rows), **{d: summarize(by_diff[d]) for d in DIFFICULTIES if by_diff[d]}}

        cats = defaultdict(list)
        for r in rows:
            if not r.get("ar_correct"):
                cats["ar: " + ar_failure(r)].append(r["question_id"])
            if not r.get("sql_correct"):
                cats["sql: " + sql_failure(r)].append(r["question_id"])
            if r.get("n_plus_one"):
                cats["perf: N+1"].append(r["question_id"])
            if overfetch(r):
                cats["perf: loads too many rows"].append(r["question_id"])
            if r.get("sql_fallback"):
                cats["style: raw SQL fallback"].append(r["question_id"])
        taxonomy[mid] = {k: {"count": len(v), "examples": v[:12]} for k, v in sorted(cats.items())}

        cfg = configs.get(mid, {"id": mid, "name": mid})
        run_date = datetime.date.fromtimestamp(f.stat().st_mtime).isoformat()
        models.append({k: cfg.get(k) for k in ("id", "name", "size", "provider")} | {"run_date": run_date})
        site_rows = [{
            "question_id": r["question_id"], "sql": r.get("sql"), "ruby": r.get("ruby"),
            "sql_correct": r.get("sql_correct"), "ar_correct": r.get("ar_correct"),
            "query_count": r.get("query_count"), "rows_loaded": r.get("rows_loaded"),
            "n_plus_one": bool(r.get("n_plus_one")), "sql_fallback": bool(r.get("sql_fallback")),
            "error": r.get("ar_error") or r.get("sql_error"),
            "queries": (r.get("queries") or [])[:20],
            "retry_ruby": r.get("retry_ruby"), "retry_n_plus_one": r.get("retry_n_plus_one"),
            "retry_query_count": r.get("retry_query_count"), "retry_ar_correct": r.get("retry_ar_correct"),
        } for r in rows]
        (SITE / "runs" / f"{mid}.json").write_text(json.dumps(site_rows, separators=(",", ":")))

        s = summary[mid]["all"]
        print(f"{mid:24} SQL {s['sql_correct']['mean']:.1%}  AR {s['ar_correct']['mean']:.1%}  "
              f"N+1 {s['n_plus_one']['mean']:.1%}  fallback {s['sql_fallback']['mean']:.1%}")

    for name, data in (("summary.json", summary), ("taxonomy.json", taxonomy)):
        (RESULTS / name).write_text(json.dumps(data, indent=1))
        (SITE / name).write_text(json.dumps(data, separators=(",", ":")))
    (SITE / "models.json").write_text(json.dumps(models, indent=1))
    print(f"Wrote summary for {len(files)} models to {RESULTS.relative_to(ROOT)} and {SITE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
