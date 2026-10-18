#!/usr/bin/env bash
# Installs Postgres in WSL Ubuntu (if missing) and loads the BIRD Mini-Dev
# PostgreSQL dump into a database called `bird`. Safe to re-run: it drops
# and recreates the database.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v psql >/dev/null; then
  sudo apt-get update
  sudo apt-get install -y postgresql postgresql-contrib
fi
sudo service postgresql start

# Postgres role matching your Ubuntu user, so plain `psql bird` works.
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$USER'" | grep -q 1 \
  || sudo -u postgres createuser --superuser "$USER"

# Both MINIDEV_mysql/ and MINIDEV_postgresql/ contain a BIRD_dev.sql - take the Postgres one.
DUMP=$(find data/raw -path '*MINIDEV_postgresql*' -name 'BIRD_dev.sql' | head -1)
[ -n "$DUMP" ] || { echo "BIRD_dev.sql not found - run scripts/01_download.sh first"; exit 1; }

mkdir -p data/processed
dropdb --if-exists bird
createdb bird
echo "Loading $DUMP (takes a few minutes) ..."
psql -q -v ON_ERROR_STOP=0 -d bird -f "$DUMP" > data/processed/load_log.txt 2>&1 || true
echo "Errors during load: $(grep -c ERROR data/processed/load_log.txt || true) (see data/processed/load_log.txt)"
# Fresh planner statistics, so EXPLAIN costs are meaningful from the first run.
psql -q -d bird -c "ANALYZE;"
psql -d bird -c "SELECT count(*) AS tables FROM information_schema.tables WHERE table_schema='public';"
psql -d bird -c "SELECT pg_size_pretty(pg_database_size('bird')) AS db_size;"
