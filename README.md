# NPlusOneBench

When LLMs write ORM code (ActiveRecord) instead of raw SQL, is it as correct, and is it production-safe?

## Data (v1)

**Source:** [BIRD Mini-Dev](https://github.com/bird-bench/mini_dev) has 500 curated BIRD-dev questions across 11 databases (148 simple / 250 moderate / 102 challenging; ~3.9M rows, 105 foreign keys). It ships an official PostgreSQL port of the databases (`BIRD_dev.sql`) and PostgreSQL gold queries. License: CC BY-SA 4.0.

All 11 databases load into **one** Postgres database, `bird`, under schema `public`. Table names don't collide, and some are mixed-case (`Patient`, `constructorResults`), so ActiveRecord models will need an explicit `self.table_name`.

## Run order (inside WSL Ubuntu, from this folder)

One command for everything:

```bash
bash scripts/run_data_pipeline.sh
```

Or step by step:

```bash
bash scripts/00_setup_wsl.sh        # apt tools + .venv
source .venv/bin/activate
bash scripts/01_download.sh         # BIRD Mini-Dev -> data/raw/
bash scripts/02_load_postgres.sh    # Postgres + `bird` database
python scripts/03_extract_schema.py # columns, PKs, FKs -> data/processed/schema.json
python scripts/04_check_gold.py     # run all 500 gold queries -> gold_check.jsonl, gold_review.csv
python scripts/05_profile_data.py   # question + database stats -> data_profile.json
```

## Outputs

| File | What it is |
|---|---|
| `data/processed/schema.json` | Per-database tables, columns, PKs, indexes, row counts, and foreign keys (taken from the SQLite originals, mapped to Postgres names). This feeds the ActiveRecord model generator. |
| `data/processed/data_profile.json` | Difficulty and database splits, SQL features used by gold queries, per-database table/FK/row counts |
| `data/processed/gold_check.jsonl` | Status, row count, and timing for every gold query |
| `data/processed/gold_review.csv` | Gold queries that errored, timed out, or returned 0 rows, to be checked by hand (fill in `verdict` / `note`) |

## Roadmap (end to end, $0 budget)

| Phase | What | Where it runs (free) |
|---|---|---|
| 1. Data | Mini-Dev in Postgres, schema + FKs, gold-query audit | WSL (local) |
| 2. Models | Generate ActiveRecord models from `schema.json` (FK -> `belongs_to` / `has_many`) | local |
| 3. Harness | Paired SQL / ActiveRecord runs; query count (`ActiveSupport::Notifications`), EXPLAIN, rows loaded into Ruby | local |
| 4. LLM runs | Small open models via Ollama (local), plus free API tiers for larger models; temperature 0, cached responses | local + free APIs |
| 5. Analysis | Accuracy + N+1 rates per difficulty, bootstrap CIs, failure taxonomy, feedback intervention | local |
| 6. Release | Public GitHub repo, one-command reproduce (Docker Compose), dataset on Hugging Face Datasets | GitHub, HF |
| 7. Deploy | Static results site + playground that replays cached model outputs (no live LLM calls) | GitHub Pages |
| 8. Write-up | Medium post (built from `docs/journal.md`) | Medium |

The full `bird` database (~4M rows) is too big for 0.5 GB free managed Postgres tiers, which is why the deployed site serves precomputed results instead of querying a live DB.
