#!/usr/bin/env bash
# Runs the whole data phase end to end (inside WSL Ubuntu). Re-runnable.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -d .venv ] || bash scripts/00_setup_wsl.sh
source .venv/bin/activate
# Re-sync Python deps every run (fast when already installed), then fail early if missing.
pip install -q -r requirements.txt
python -c "import psycopg" || { echo "psycopg failed to install - see pip output above"; exit 1; }
bash scripts/01_download.sh
bash scripts/02_load_postgres.sh
python scripts/03_extract_schema.py
python scripts/04_check_gold.py
python scripts/05_profile_data.py
