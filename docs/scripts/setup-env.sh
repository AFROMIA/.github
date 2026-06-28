#!/usr/bin/env bash
# Configure les fichiers .env pour un profil AFROMIA (docker | local | supabase)
set -euo pipefail

PROFILE="${1:-}"
if [[ ! "$PROFILE" =~ ^(docker|local|supabase)$ ]]; then
  echo "Usage: $0 <docker|local|supabase>"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATE="$ROOT/docs/env-profiles/${PROFILE}.env.example"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template introuvable: $TEMPLATE"
  exit 1
fi

cp "$TEMPLATE" "$ROOT/SAFIRI/.env"

if [[ "$PROFILE" == "docker" ]]; then
  cat > "$ROOT/AFFINIORA/.env" <<'EOF'
ENVIRONMENT=development
MODEL_CACHE_DIR=/models/cache
REDIS_URL=redis://redis:6379/3
EOF
else
  cat > "$ROOT/AFFINIORA/.env" <<'EOF'
ENVIRONMENT=development
MODEL_CACHE_DIR=./models/cache
REDIS_URL=redis://localhost:6380/3
EOF
fi

echo ""
echo "Profil '$PROFILE' appliqué :"
echo "  $ROOT/SAFIRI/.env"
echo "  $ROOT/AFFINIORA/.env"

if [[ "$PROFILE" == "supabase" ]] && grep -qE '\[PROJECT_REF\]|\[PASSWORD\]|\[REGION\]' "$ROOT/SAFIRI/.env"; then
  echo ""
  echo "ATTENTION: éditez SAFIRI/.env avec vos identifiants Supabase"
  echo "  Extensions requises : postgis, vector"
fi

echo ""
echo "Prochaine étape : docs/scripts/dev.sh $PROFILE"
