#!/usr/bin/env bash
# One-time setup inside WSL Ubuntu: base tools + a Python venv for the data scripts.
set -euo pipefail
cd "$(dirname "$0")/.."
sudo apt-get update
sudo apt-get install -y curl unzip git python3-venv python3-pip
python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
echo "Ready. Activate with: source .venv/bin/activate"
