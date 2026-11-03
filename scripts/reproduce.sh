#!/usr/bin/env bash
# Everything after the LLM calls, from the cached answers in data/runs/.
#   bash scripts/reproduce.sh            score cached answers only
#   bash scripts/reproduce.sh --llm      ask the models first (needs Ollama / API keys)
set -euo pipefail
cd "$(dirname "$0")/.."

bash scripts/run_data_pipeline.sh
python scripts/06_export_site_data.py
python scripts/07_generate_models.py

models=$(python3 -c "import json; print(' '.join(m['id'] for m in json.load(open('config/models.json'))))")
for m in $models; do
  if [ "${1:-}" = "--llm" ]; then
    python scripts/08_run_models.py "$m" || { echo "skipping $m"; continue; }
  fi
  [ -d "data/runs/$m" ] || continue
  python scripts/09_evaluate.py "$m"
  if [ "${1:-}" = "--llm" ]; then
    python scripts/08_run_models.py "$m" --kind ar_retry && python scripts/09_evaluate.py "$m"
  fi
done
python scripts/10_analyze.py
