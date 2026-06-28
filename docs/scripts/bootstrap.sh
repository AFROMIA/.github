#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SAFIRI="$ROOT/SAFIRI"
AFFINIORA="$ROOT/AFFINIORA"
ENV_TEMPLATE="$ROOT/docs/env-profiles/local.env.example"

echo "==> Bootstrapping AFROMIA (SAFIRI + AFFINIORA)..."

if [[ ! -f "$SAFIRI/.env" ]]; then
  if [[ -f "$ENV_TEMPLATE" ]]; then
    cp "$ENV_TEMPLATE" "$SAFIRI/.env"
  elif [[ -f "$SAFIRI/.env.example" ]]; then
    cp "$SAFIRI/.env.example" "$SAFIRI/.env"
  fi
  echo "Created SAFIRI/.env"
fi

if [[ ! -f "$AFFINIORA/.env" ]] && [[ -f "$AFFINIORA/.env.example" ]]; then
  cp "$AFFINIORA/.env.example" "$AFFINIORA/.env"
  echo "Created AFFINIORA/.env"
fi

echo "==> Installing npm workspaces (SAFIRI)..."
(cd "$SAFIRI" && npm install)

echo "==> Installing Python dependencies..."
pip install -e "$SAFIRI/apps/backend/[dev]"
pip install -e "$AFFINIORA/services/ai-engine/[dev]"

echo "==> Installing pre-commit hooks (SAFIRI)..."
if command -v pre-commit &> /dev/null && [[ -f "$SAFIRI/.pre-commit-config.yaml" ]]; then
  (cd "$SAFIRI" && pre-commit install)
else
  echo "pre-commit not found or config absent — install with: pip install pre-commit"
fi

echo ""
echo "Bootstrap complete. Run: docs/scripts/dev.sh local"
