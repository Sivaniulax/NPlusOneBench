#!/usr/bin/env bash
# Downloads BIRD Mini-Dev (500 curated BIRD-dev questions, with an official
# PostgreSQL port of the 11 databases) into data/raw/ and unzips it.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/raw
URL="https://bird-bench.oss-cn-beijing.aliyuncs.com/minidev.zip"
if [ ! -f data/raw/minidev.zip ]; then
  echo "Downloading $URL ..."
  curl -L --fail -o data/raw/minidev.zip "$URL"
fi
if [ -z "$(find data/raw -path '*MINIDEV_postgresql*' -name 'BIRD_dev.sql' 2>/dev/null)" ]; then
  echo "Unzipping ..."
  unzip -q -o data/raw/minidev.zip -d data/raw/
else
  echo "Already unzipped, skipping."
fi
echo "Done. Key files:"
find data/raw -name 'BIRD_dev.sql' -o -name 'mini_dev_postgresql.json' -o -name 'mini_dev_pg*.json' | head
echo "SQLite DBs: $(find data/raw -name '*.sqlite' | wc -l) (expected 11)"
