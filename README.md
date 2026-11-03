# NPlusOneBench

A benchmark for LLM-generated ORM code. Each model answers the same natural-language database questions twice, once in SQL and once in Ruby on Rails ActiveRecord. Both answers are executed and compared with the gold result. ActiveRecord answers are also profiled: number of queries sent, records loaded into Ruby, N+1 query patterns, and fallback to raw SQL.

Results site: https://sivaniulax.github.io/NPlusOneBench/

## What is measured

| Metric | Definition |
|---|---|
| SQL accuracy | Model's SQL returns the gold result set |
| ActiveRecord accuracy | Value of the model's Ruby code returns the gold result set |
| AR − SQL | Paired difference in accuracy on the same questions |
| N+1 rate | Answers where the same query shape (literals removed) runs 3 or more times |
| Over-fetch rate | Answers that load ≥ 1,000 records and more than 10× the rows in the gold result |
| Raw SQL fallback | Ruby code that calls `find_by_sql`, `connection.execute`, `Arel.sql` or similar |
| Feedback fix rate | Share of N+1 answers that no longer have an N+1 after one retry with the repeated query shown |

Result sets are compared as unordered sets of rows, as in BIRD, with a relative tolerance of 1e-4 on floating-point values. Accuracy and rates are reported with 95% bootstrap intervals (2,000 resamples).

## Dataset

Questions and databases come from [BIRD Mini-Dev](https://github.com/bird-bench/mini_dev) (CC BY-SA 4.0), using its PostgreSQL port.

| | |
|---|---|
| Questions | 498 (148 simple, 248 moderate, 102 challenging) |
| Databases | 11, loaded into one PostgreSQL database `bird` |
| Tables | 75 |
| Rows | 3.9 million |
| Foreign keys | 105 |

Every PostgreSQL gold query was executed and its result compared with the original SQLite gold query on the SQLite database. All 498 match after the following corrections:

- **Time zone.** The dump stores timestamps as `timestamptz` at UTC+8, and the gold SQL compares them with local-time literals. The `bird` database is set to `Asia/Shanghai`.
- **Question 788.** The PostgreSQL gold query computed a different percentage than the SQLite gold query and the evidence text. It is replaced in `data/gold_fixes.json`.
- **Duplicates.** Questions 137 and 138 appear twice in Mini-Dev and are counted once.

## How it works

1. The schema of each database is extracted from PostgreSQL and the SQLite originals (`03_extract_schema.py`).
2. ActiveRecord models are generated from it (`07_generate_models.py`): one class per table, `belongs_to` and `has_many` from the foreign keys, annotate-style column comments, `alias_attribute` for column names that are not valid Ruby identifiers, and composite primary keys where needed. 75 models, 104 associations in each direction.
3. Each model is prompted twice per question (`08_run_models.py`): with `CREATE TABLE` statements for SQL, and with the model files for ActiveRecord. Temperature 0. Responses are cached by prompt hash.
4. SQL answers run in PostgreSQL. ActiveRecord answers run in `harness/run.rb`, one process per database, inside a read-only transaction with a 30 s statement timeout. `ActiveSupport::Notifications` records every query and every instantiated record (`09_evaluate.py`).
5. Answers flagged as N+1 are sent back once with the repeated query, and the rewrite is scored again (`08_run_models.py --kind ar_retry`).
6. `10_analyze.py` computes the metrics and failure categories and writes the site's data files.

## Requirements

- PostgreSQL 16+
- Python 3.12+ (`requirements.txt`)
- Ruby 3.3+ with Bundler (`harness/Gemfile`: ActiveRecord 8, pg)
- Node 22 for the site
- An OpenAI-compatible model endpoint: [Ollama](https://ollama.com) locally, or an API key in `GROQ_API_KEY` / `GEMINI_API_KEY`. Models are listed in `config/models.json`.

## Usage

With Docker:

```bash
docker compose up --build                  # data pipeline and scoring of cached answers
docker compose --profile llm up --build    # also starts an Ollama container
```

On Ubuntu or WSL:

```bash
bash scripts/00_setup_wsl.sh                         # system packages and Python venv
(cd harness && bundle config set --local path vendor/bundle && bundle install)
bash scripts/reproduce.sh                            # data pipeline, scoring, analysis
bash scripts/reproduce.sh --llm                      # same, querying the models first
```

A single model:

```bash
ollama pull qwen2.5-coder:3b
python scripts/08_run_models.py qwen2.5-coder-3b
python scripts/09_evaluate.py qwen2.5-coder-3b
python scripts/08_run_models.py qwen2.5-coder-3b --kind ar_retry
python scripts/09_evaluate.py qwen2.5-coder-3b
python scripts/10_analyze.py
```

## Scripts

| Script | Output |
|---|---|
| `01_download.sh` | `data/raw/` |
| `02_load_postgres.sh` | `bird` database |
| `03_extract_schema.py` | `data/processed/schema.json` |
| `04_check_gold.py` | `data/processed/gold_check.jsonl` |
| `05_profile_data.py` | `data/processed/data_profile.json` |
| `06_export_site_data.py` | `web/public/data/` |
| `07_generate_models.py` | `harness/models/<db_id>/` |
| `08_run_models.py` | `data/runs/<model>/` |
| `09_evaluate.py` | `data/results/<model>.jsonl` |
| `10_analyze.py` | `data/results/summary.json`, `taxonomy.json` |
| `11_export_dataset.py` | `data/hf/` (Hugging Face dataset) |

`run_data_pipeline.sh` runs steps 01–05.

## Security note

The harness evaluates model-generated Ruby with `eval`. Database writes are blocked by the read-only transaction, but the process itself is not sandboxed. Use the Docker setup when running untrusted models.

## License

Code: MIT. Data derived from BIRD Mini-Dev: CC BY-SA 4.0.
