"""Write the JSON files the React site reads into web/public/data/.

questions.json  every question with gold SQL and its audit result
dataset.json    dataset profile + audit summary
models.json     models that have runs (empty until phase 4)
"""
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROC = ROOT / "data" / "processed"
OUT = ROOT / "web" / "public" / "data"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    gold = [json.loads(l) for l in (PROC / "gold_check.jsonl").read_text().splitlines() if l]

    questions = [{
        "question_id": g["question_id"],
        "db_id": g["db_id"],
        "difficulty": g["difficulty"],
        "question": g["question"],
        "evidence": g.get("evidence", ""),
        "gold_sql": g["sql"],
        "gold_status": g["status"],
        "gold_rows": g.get("n_rows"),
        "gold_preview": g.get("preview"),
        "gold_ms": g.get("ms"),
        "sqlite_match": g.get("sqlite_match"),
        "gold_fixed": g.get("gold_fixed", False),
    } for g in gold]
    questions.sort(key=lambda q: q["question_id"])

    dataset = json.loads((PROC / "data_profile.json").read_text())
    dataset["gold_audit"] = dict(Counter(g["status"] for g in gold))
    dataset["gold_unverified"] = [g["question_id"] for g in gold if g.get("sqlite_match") is None]

    runs = sorted(p.stem for p in (OUT / "runs").glob("*.json")) if (OUT / "runs").exists() else []
    models_file = OUT / "models.json"
    if not models_file.exists() or not runs:
        models_file.write_text("[]\n")

    (OUT / "questions.json").write_text(json.dumps(questions, separators=(",", ":")))
    (OUT / "dataset.json").write_text(json.dumps(dataset, indent=1))
    print(f"Wrote {len(questions)} questions to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
