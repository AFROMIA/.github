#!/usr/bin/env bash
# Lance AFROMIA en local selon le profil : docker | local | supabase
set -euo pipefail

MODE="${1:-}"
SKIP_MIGRATE=false
SKIP_SEED=false
WITH_SEED=false
SKIP_AFFINIORA=false

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-migrate) SKIP_MIGRATE=true ;;
    --skip-seed) SKIP_SEED=true ;;
    --with-seed) WITH_SEED=true ;;
    --skip-affiniora) SKIP_AFFINIORA=true ;;
    *) echo "Option inconnue: $1"; exit 1 ;;
  esac
  shift
done

if [[ ! "$MODE" =~ ^(docker|local|supabase)$ ]]; then
  echo "Usage: $0 <docker|local|supabase> [--skip-migrate] [--with-seed] [--skip-affiniora]"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPTS="$ROOT/docs/scripts"
SAFIRI="$ROOT/SAFIRI"
BACKEND="$SAFIRI/apps/backend"
ENV_FILE="$SAFIRI/.env"

ensure_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "Configuration du profil '$MODE'..."
    "$SCRIPTS/setup-env.sh" "$MODE"
  fi
}

wait_postgres() {
  local cid
  cid="$(cd "$SAFIRI" && docker compose ps -q postgres)"
  if [[ -z "$cid" ]]; then
    echo "Conteneur postgres introuvable"
    exit 1
  fi
  echo "Attente de PostgreSQL..."
  for _ in $(seq 1 30); do
    if docker exec "$cid" pg_isready -U afromia >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "PostgreSQL n'est pas prêt après 60s"
  exit 1
}

start_infra() {
  echo "Démarrage infra Docker (postgres, redis, minio, livekit, coturn)..."
  (cd "$SAFIRI" && docker compose up -d postgres redis minio livekit coturn)
  wait_postgres
  if [[ "$SKIP_AFFINIORA" == "false" ]]; then
    echo "Démarrage AFFINIORA..."
    (cd "$ROOT/AFFINIORA" && docker compose up -d redis ai-engine)
  fi
}

start_infra_support() {
  echo "Démarrage Redis + MinIO + LiveKit + coturn..."
  (cd "$SAFIRI" && docker compose up -d redis minio livekit coturn)
  if [[ "$SKIP_AFFINIORA" == "false" ]]; then
    (cd "$ROOT/AFFINIORA" && docker compose up -d redis ai-engine)
  fi
}

run_migrate() {
  if [[ "$SKIP_MIGRATE" == "true" ]]; then return; fi
  echo "Migrations Alembic..."
  export ENV_FILE="$ENV_FILE"
  if [[ "$MODE" == "docker" ]]; then
    export DATABASE_URL="postgresql+asyncpg://afromia:afromia@localhost:5432/afromia"
    export DATABASE_URL_SYNC="postgresql+psycopg://afromia:afromia@localhost:5432/afromia"
    export DATABASE_SSL=false
  fi
  (cd "$BACKEND" && alembic upgrade head)
}

run_seed() {
  if [[ "$WITH_SEED" != "true" ]]; then
    echo "Fixtures non chargees au demarrage — Debug Panel ou: make seed"
    return
  fi
  if [[ "$SKIP_SEED" == "true" ]]; then return; fi
  echo "Seed / fixtures..."
  export ENV_FILE="$ENV_FILE"
  if [[ "$MODE" == "docker" ]]; then
    export DATABASE_URL="postgresql+asyncpg://afromia:afromia@localhost:5432/afromia"
    export DATABASE_URL_SYNC="postgresql+psycopg://afromia:afromia@localhost:5432/afromia"
    export DATABASE_SSL=false
  fi
  (cd "$BACKEND" && python scripts/seed_data.py)
}

start_local_apps() {
  echo ""
  echo "=== Apps locales ==="
  echo "  Frontend  : http://localhost:3000"
  echo "  Backend   : http://localhost:8000/docs"
  echo "  LiveKit   : ws://localhost:7880"
  echo "  TURN      : turn:localhost:3478"
  echo ""

  export ENV_FILE="$ENV_FILE"
  (cd "$SAFIRI" && npm run dev:local)
}

ensure_env

case "$MODE" in
  docker)
    echo "=== Mode DOCKER (stack complet) ==="
    if [[ "$SKIP_MIGRATE" == "false" ]]; then
      (cd "$SAFIRI" && docker compose up -d postgres redis minio livekit coturn)
      wait_postgres
      run_migrate
      run_seed
    fi
    (cd "$SAFIRI" && docker compose up --build)
    ;;
  local)
    echo "=== Mode LOCAL (apps locales + Postgres Docker) ==="
    start_infra
    run_migrate
    run_seed
    start_local_apps
    ;;
  supabase)
    echo "=== Mode SUPABASE (apps locales + base Supabase) ==="
    if grep -qE '\[PROJECT_REF\]|\[PASSWORD\]|\[REGION\]' "$ENV_FILE"; then
      echo "Configurez d'abord SAFIRI/.env avec vos identifiants Supabase"
      exit 1
    fi
    start_infra_support
    run_migrate
    run_seed
    start_local_apps
    ;;
esac
