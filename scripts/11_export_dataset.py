"""Build the Hugging Face dataset folder in data/hf/.

    python scripts/11_export_dataset.py
    huggingface-cli upload <user>/nplusonebench data/hf --repo-type dataset

questions.jsonl  498 questions, gold SQL (with our fixes), schema prompts
answers.jsonl    every model answer with its scores, once there are runs
models/          the generated ActiveRecord models, one folder per database
"""
import importlib.util
import json
import shutil

from common import ROOT, load_questions

HF = ROOT / "data" / "hf"
RESULTS = ROOT / "data" / "results"

spec = importlib.util.spec_from_file_location("runner", ROOT / "scripts" / "08_run_models.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def main():
    HF.mkdir(parents=True, exist_ok=True)
    gold = {json.loads(l)["question_id"]: json.loads(l) for l in (ROOT / "data" / "processed" / "gold_check.jsonl").read_text().splitlines()}
    with open(HF / "questions.jsonl", "w") as f:
        for q in load_questions():
            g = gold.get(q["question_id"], {})
            f.write(json.dumps({
                "question_id": q["question_id"], "db_id": q["db_id"], "difficulty": q["difficulty"],
                "question": q["question"], "evidence": q.get("evidence", ""), "gold_sql": q["SQL"],
                "gold_fixed": q.get("gold_fixed", False), "gold_rows": g.get("n_rows"),
                "schema_sql": runner.create_tables(q["db_id"]),
            }) + "\n")

    answers = 0
    with open(HF / "answers.jsonl", "w") as f:
        for p in sorted(RESULTS.glob("*.jsonl")):
            if p.stem.startswith("_"):
                continue
            for line in p.read_text().splitlines():
                r = json.loads(line)
                r.pop("queries", None)
                f.write(json.dumps({"model": p.stem, **r}) + "\n")
                answers += 1

    if (HF / "models").exists():
        shutil.rmtree(HF / "models")
    shutil.copytree(ROOT / "harness" / "models", HF / "models")
    shutil.copy(ROOT / "docs" / "dataset_card.md", HF / "README.md")
    print(f"Wrote {HF.relative_to(ROOT)}: questions.jsonl, answers.jsonl ({answers} answers), models/")


if __name__ == "__main__":
    main()
