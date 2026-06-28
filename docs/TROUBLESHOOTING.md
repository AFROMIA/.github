# AFROMIA — Depannage dev local

## Docker Hub inaccessible (`auth.docker.io: no such host`)

Symptome :
```
lookup auth.docker.io: no such host
failed to fetch anonymous token
```

### Correctifs (Windows + Docker Desktop)

1. Ouvrir **Docker Desktop** > **Settings** > **Docker Engine**
2. Ajouter ou completer la section DNS :
```json
{
  "dns": ["8.8.8.8", "1.1.1.1"]
}
```
3. **Apply & Restart**
4. Tester :
```powershell
docker pull postgis/postgis:16-3.4
docker pull redis:7-alpine
docker pull minio/minio:latest
```

### Image Postgres avec pgvector (quand le reseau fonctionne)

```powershell
docker pull garapadev/postgres-postgis-pgvector:16-stable
```

Puis dans `SAFIRI/docker-compose.yml`, remplacer l'image postgres par :
`garapadev/postgres-postgis-pgvector:16-stable`

### Mode hors-ligne (images deja en cache)

`make dev` detecte automatiquement les images Postgres locales (`postgis/postgis`, `postgres:16-alpine`, etc.)
et genere un override compose (`SAFIRI/docker-compose.postgres-override.yml`).

Ordre de priorite :
1. Image PostGIS en cache (`postgis/postgis:16-3.4`)
2. Autre image Postgres locale (`postgres:16-alpine`, `postgres:16`, ...)
3. Tentative de pull (si reseau OK)
4. Fallback PostgreSQL installe sur Windows (port `5432` deja ouvert)

**Attention** : `postgres:16-alpine` seul n'inclut pas PostGIS ni pgvector. Le script detecte ce cas et recree le conteneur avec **`afromia-postgres:16`** (PostGIS + pgvector).

Premier lancement (build une fois, ~2 min) :
```powershell
docker pull postgis/postgis:16-3.4
# puis make dev construit automatiquement afromia-postgres:16
```

Si aucune image ni service local n'est disponible, le script affiche les instructions DNS ci-dessus.

## Port 5432 occupe par un autre Postgres (`password authentication failed for user afromia`)

Symptome : un autre conteneur (ex. `maresa-postgres`) ecoute deja sur `:5432`.

Le script utilise **le port 5432 par defaut**. Si 5432 est occupe par un autre Postgres (sans user `afromia`), il bascule automatiquement sur le premier port libre (5433, 5434, ...) et ajuste `DATABASE_URL` pour la session.

Relancer :
```powershell
powershell -ExecutionPolicy Bypass -File docs\scripts\dev.ps1 -Mode local -SkipAffiniora
```

Pour utiliser le port 5432 : arreter l'autre Postgres (`docker stop maresa-postgres`) puis relancer.

## Next.js : warnings "multiple modules with names that only differ in casing"

Symptome (Windows) :
```
IronCorp technologies\AFROMIA\SAFIRI\...
IronCorp technologies\Afromia\SAFIRI\...
```

Cause : le meme dossier est reference avec deux casses (`AFROMIA` vs `Afromia`).

Cause reelle : Windows conserve la casse du disque (`AFROMIA`) mais Node/webpack peut referencer `Afromia` selon comment vous ouvrez le dossier. Webpack charge alors **deux fois** les memes modules → `Invalid hook call`, `useContext` null, `layout router to be mounted`, **GET / 500**.

Correctifs (automatiques depuis le fix) :
- `SAFIRI/scripts/resolve-true-case.mjs` — normalise tous les chemins vers la casse disque (`AFROMIA`)
- `SAFIRI/scripts/dev-frontend.mjs` — lance Next depuis ce chemin canonique
- `docs/scripts/dev.ps1` — `Resolve-TrueCasePath` pour la racine du projet

Relance propre :
```powershell
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Recurse -Force SAFIRI\apps\frontend\.next -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File docs\scripts\dev.ps1 -Mode local -SkipAffiniora
```

**Ne pas** forcer `react`/`next` dans `webpack.resolve.alias` sous Next.js 15 App Router — cela cree une 2e copie de React.

Si erreur **"invariant expected layout router to be mounted"** :
Pas besoin de `make bootstrap` — arreter les anciens serveurs, nettoyer, relancer :

```powershell
cd "C:\Users\MAITRE\Documents\IronCorp technologies\Afromia"
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Recurse -Force SAFIRI\apps\frontend\.next -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File docs\scripts\dev.ps1 -Mode local -SkipAffiniora
```

Puis ouvrir http://localhost:3000 (pas 3001 — un ancien processus peut bloquer le port).

## pip AFFINIORA echoue (scipy/torch)

AFFINIORA tourne via **Docker** — le pip local n'est pas requis :
```powershell
make bootstrap          # sans AFFINIORA pip
make dev                # demarre ai-engine dans Docker
```

## uvicorn / alembic introuvable

Les scripts utilisent `python -m uvicorn` et `python -m alembic`.
Verifier : `python -m pip show uvicorn alembic`

## Affiniora : `unable to get image affiniora-ai-engine` / Internal Server Error Docker

Symptome :
```
unable to get image 'affiniora-ai-engine': request returned Internal Server Error
... dockerDesktopLinuxEngine ...
```

### Cause

1. **Docker Desktop** instable ou pas completement demarre (API 500)
2. **Image jamais construite** (premier lancement Affiniora)

### Correctifs

```powershell
# 1) Redemarrer Docker Desktop (icone baleine > Restart)
# 2) Verifier que le moteur repond
docker info

# 3) Build explicite (5-15 min la 1ere fois - PyTorch CPU)
make dev-affiniora-build

# 4) Puis lancer
make dev-affiniora
```

Si `docker info` echoue ou reste bloque : redemarrer Windows puis Docker Desktop.

## Affiniora : crash au chargement Qwen (`Loading weights` puis traceback uvicorn)

Symptome dans les logs `make dev-affiniora` :

```
loading_sarielle_llm  device=cpu model=Qwen/Qwen2.5-1.5B-Instruct
Loading weights:   0%|          | 0/338 ...
Traceback ... uvicorn ... ChangeReload ...
```

### Cause

1. **Preload au demarrage** : Qwen 1.5B en CPU demande plusieurs Go de RAM ; Docker Desktop Windows (souvent 2–4 Go alloues) tue le worker → uvicorn reload en boucle.
2. **Rafale de `/health`** (debug panel) : aggrave la pression memoire pendant le chargement — corrige cote frontend (TTL 30 s sur `useAffinioraHealth`).

### Correctifs

```powershell
# 1) Profil dev : preload desactive dans docker-compose.dev.yml (redemarrer Affiniora)
make dev-affiniora

# 2) Augmenter la RAM Docker Desktop : Settings > Resources > Memory (8 Go recommande si preload voulu)

# 3) Preload manuel (prod / machine puissante) dans AFFINIORA/.env :
#    SARIELLE_PRELOAD_LLM=true
#    LAZY_LOAD_MODELS=false
```

Sans preload, `/health` et le debug panel restent OK ; Sarielle repond en mode template puis charge le LLM au premier message.

## Backend hot reload qui fait tomber le frontend

Symptome : apres `WatchFiles detected changes ... Reloading...`, le backend ne repond plus **et** `http://localhost:3000` affiche `ERR_CONNECTION_REFUSED`.

### Cause

`make dev` lance backend + frontend dans **un seul terminal** via `concurrently` (`npm run dev:local`). Si uvicorn plante pendant un reload (erreur Python, import casse), le process backend s'arrete. En pratique :

- fermer le terminal ou Ctrl+C tue les deux processus ;
- relancer `make dev` redemarre tout (frontend inclus) ;
- une erreur de syntaxe dans `app/` empeche uvicorn de repartir apres le reload.

Le frontend n'a pas besoin du backend pour ecouter sur le port 3000, mais il est lance dans la meme session.

### Workflow decouple (recommande)

**Une commande — grille 2x2 Windows Terminal** (infra ici, 4 services sur une page) :

```powershell
make dev-split
```

Sans Celery : `powershell -File docs\scripts\start-split.ps1 -SkipCelery`

Ou terminaux manuels :

```powershell
make dev-infra      # Docker + migrations (puis fermer)
make dev-backend
make dev-frontend
make dev-affiniora
make celery
```

Affiniora tourne **deja dans Docker** (port `8001`), independamment du backend/frontend locaux. Un reload uvicorn dans le conteneur ai-engine **ne touche pas** le frontend Next.js.

Ou directement via npm dans `SAFIRI/` :

```powershell
npm run dev:backend   # terminal dedie
npm run dev:frontend  # autre terminal
```

Le backend redemarre automatiquement apres un crash (jusqu'a 50 tentatives). Le frontend reste accessible meme si l'API est temporairement down.

### Garder `make dev` (tout-en-un)

Toujours possible pour un demarrage rapide. Ameliorations :

- le backend se relance seul apres un crash ;
- un echec backend n'impose plus un code de sortie bloquant pour le frontend (`concurrently --success "!command-backend"`).

Si le reload uvicorn reste bloque, relancer uniquement le backend : `make dev-backend` (sans toucher au frontend).

## bootstrap.ps1 : erreur « Accolade fermante } manquante » (ligne ~86)

Cause : **Windows PowerShell 5.1** mal interprete les tirets Unicode (`—`) dans les commentaires du script (encodage UTF-8 sans BOM).

Correctif deja applique dans `docs/scripts/bootstrap.ps1` (ASCII uniquement dans les commentaires).

Si l'erreur persiste, relancer :

```powershell
powershell -ExecutionPolicy Bypass -File docs\scripts\bootstrap.ps1
```

Ou utiliser **PowerShell 7+** (`pwsh`) si installe.
