# Changelog

## 0.1.0 (2026-10-19): Data phase

### Added
- Project scaffold: README with the research question and an end-to-end roadmap ($0 budget), `.gitignore`, `.gitattributes` (LF endings so the scripts run in WSL), `requirements.txt`.
- `scripts/00_setup_wsl.sh`: apt tools and a Python venv inside WSL Ubuntu.
- `scripts/01_download.sh`: downloads and unzips BIRD Mini-Dev (500 questions, 11 databases, official Postgres port).
- `scripts/02_load_postgres.sh`: installs Postgres, loads everything into one `bird` database, and runs `ANALYZE`.
- `scripts/03_extract_schema.py`: columns, PKs, indexes, row counts, and FKs (from the SQLite originals) to `schema.json`. Flags any Postgres/SQLite row-count mismatch.
- `scripts/04_check_gold.py`: runs all 500 gold queries and lists errors, timeouts, and empty results in `gold_review.csv` for hand review.
- `scripts/05_profile_data.py`: dataset statistics to `data_profile.json`.
- `scripts/run_data_pipeline.sh`: one command for the whole data phase.
- `docs/journal.md`: build log for the Medium write-up.

### Fixed
- The load script picked `MINIDEV_mysql/BIRD_dev.sql` instead of the Postgres dump (both have the same filename), which caused 52 syntax errors. It now selects the file under `MINIDEV_postgresql/`.

### Not yet done
- Postgres load and gold-query audit still need a rerun with the fixed script (`schema.json` and `gold_review.csv` don't exist yet).
