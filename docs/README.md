# AFROMIA — Guide développeur local

Documentation centrale pour lancer et utiliser les deux produits de l'écosystème en local :

| Produit | Rôle | Interface dev |
|---------|------|---------------|
| **SAFIRI** | Application de rencontre (PWA) | http://localhost:3000 |
| **AFFINIORA** | Moteur IA (scoring, personnalité, anti-fake) | http://localhost:8001/docs |

Les deux services communiquent **uniquement par API REST**. SAFIRI appelle AFFINIORA via `AFFINIORA_API_URL`.

```
AFROMIA/
├── SAFIRI/       # Frontend Next.js + Backend FastAPI
├── AFFINIORA/    # Microservice ai-engine (Docker)
└── docs/         # Ce guide, scripts de démarrage, profils .env
```

---

## Prérequis

- **Docker Desktop** (Postgres, Redis, MinIO, AFFINIORA)
- **Node.js ≥ 20**
- **Python ≥ 3.12**
- **Git** + **Make** (optionnel, recommandé sous Windows avec PowerShell)

Ouvrir toujours le projet avec la casse exacte du disque : `AFROMIA` (pas `Afromia`).

---

## Installation (première fois)

Depuis la racine `AFROMIA/` :

```powershell
cd "C:\Users\MAITRE\Documents\IronCorp technologies\AFROMIA"

# Dépendances npm (SAFIRI) + pip backend — sans PyTorch local
make bootstrap

# Fichiers .env (SAFIRI/.env + AFFINIORA/.env)
make env-local
```

Vérifier dans `SAFIRI/.env` :

```env
AFFINIORA_API_URL=http://localhost:8001
DATABASE_URL=postgresql+asyncpg://afromia:afromia@localhost:5432/afromia
REDIS_URL=redis://localhost:6379/0
S3_ENDPOINT_URL=http://localhost:9000
```

AFFINIORA tourne en **Docker** : inutile d'installer PyTorch/scipy en local.

---

## Démarrage rapide (recommandé)

Une commande lance l'infra Docker + migrations + apps :

```powershell
make dev
```

Équivalent :

```powershell
powershell -ExecutionPolicy Bypass -File docs\start.ps1 -Mode local
```

Double-clic Windows : `docs\start.bat`

### Ce que fait `make dev`

| Étape | Où | Quoi |
|-------|-----|------|
| 1 | Docker (SAFIRI) | Postgres `:5432`, Redis `:6379`, MinIO `:9000` |
| 2 | Docker (AFFINIORA) | Redis `:6380`, ai-engine `:8001` |
| 3 | Local | `alembic upgrade head` + seed données de test |
| 4 | Local | Backend `:8000` + Frontend `:3000` |

**Premier build AFFINIORA** : le conteneur installe PyTorch CPU (~5–15 min). C'est normal.

### URLs une fois démarré

| Service | URL | Identifiants |
|---------|-----|--------------|
| **SAFIRI** (app) | http://localhost:3000 | Comptes seed ou inscription |
| **SAFIRI API** | http://localhost:8000/docs | Swagger backend |
| **AFFINIORA API** | http://localhost:8001/docs | Swagger IA |
| **MinIO** (médias) | http://localhost:9001 | `minioadmin` / `minioadmin` |
| **Logs session** | `logs/latest.log` | Sortie centralisée |

---

## Démarrage manuel (débogage)

Utile si AFFINIORA ou Postgres ne démarre pas via `make dev`.

### Terminal 1 — Infra SAFIRI (Docker)

```powershell
cd SAFIRI
docker compose up -d postgres redis minio
docker compose ps
```

Attendre Postgres :

```powershell
docker exec $(docker compose ps -q postgres) pg_isready -U afromia
```

### Terminal 2 — AFFINIORA (Docker)

```powershell
cd AFFINIORA
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
docker compose up --build redis ai-engine
```

Vérifier :

```powershell
curl http://localhost:8001/health
# {"status":"healthy","service":"affiniora-ai"}
```

### Terminal 3 — Migrations + apps SAFIRI

```powershell
cd ..
make migrate
make seed

cd SAFIRI
npm run dev:local
```

### Terminal 4 — Celery (tâches IA asynchrones)

Requis pour : analyse personnalité post-quiz, scores de compatibilité, vérif vidéo, notifications.

```powershell
cd SAFIRI\apps\backend
$env:ENV_FILE = "..\..\.env"
python -m celery -A app.workers.celery_app worker --loglevel=info
```

---

## Utiliser SAFIRI en local

### Parcours utilisateur type

1. **Inscription** → http://localhost:3000/register
2. **Onboarding** → profil + quiz personnalité (AFFINIORA analyse en arrière-plan)
3. **Personnalité** → http://localhost:3000/personality (résultats Affiniora)
4. **Vérification vidéo** → http://localhost:3000/verify-video (selfie 10–30 s)
5. **Discover** → swipe, scores de compatibilité affichés sur les cartes
6. **Match** → messagerie temps réel, suggestions IA dans le chat
7. **Premium / Live / Blog** → `/premium`, `/live`, `/blog`

### Comptes de test (seed)

```powershell
make seed          # charge les fixtures
make fixtures-status   # état du seed
```

Voir [COMPTES_TEST.md](./COMPTES_TEST.md) pour la liste complète des comptes, rôles et connexions.

### Fonctionnalités clés

| Fonction | Dépend de |
|----------|-----------|
| Scores Discover | AFFINIORA + backend |
| Quiz → profil IA | AFFINIORA + **Celery** |
| Match + chat | Postgres + Redis |
| Upload photos | MinIO (S3 local) |
| Admin / modération | http://localhost:3000/admin (rôle admin seed) |

---

## Utiliser AFFINIORA en local

AFFINIORA est un **microservice API** : pas d'interface utilisateur dédiée. On l'utilise via :

### 1. Swagger

http://localhost:8001/docs

Endpoints principaux :

| Méthode | Route | Usage |
|---------|-------|-------|
| POST | `/v1/score/compatibility` | Score entre deux profils (v1) |
| POST | `/v1/analyze/personality` | Dimensions personnalité (v1) |
| POST | `/v1/analyze/profile-full` | Analyse complète UserProfileIA (v2) |
| POST | `/v1/coaching/regenerate` | Plan coaching selon goal_type (v2) |
| POST | `/v1/chat/sarielle` | Agent Sarielle avec RAG + coaching (v2) |
| POST | `/v1/detect/fake-profile` | Détection profil suspect |
| POST | `/v1/suggest/conversation` | Suggestions de messages |
| POST | `/v1/translate` | Traduction |

Contrat détaillé : [AFFINIORA/docs/CONTRACT_V2.md](../AFFINIORA/docs/CONTRACT_V2.md).

### 2. Depuis SAFIRI (intégration réelle)

- **Discover** : score affiché sur chaque carte profil
- **Onboarding** : analyse après le quiz
- **Chat** : bouton « Suggestions IA »
- **Admin** : onglet test Affiniora → http://localhost:3000/admin

### 3. Test curl direct

```powershell
curl -X POST http://localhost:8001/v1/score/compatibility `
  -H "Content-Type: application/json" `
  -d '{
    "profile_a_id": "user-a",
    "profile_b_id": "user-b",
    "profile_a_data": {"bio": "voyage aventure Afrique", "interests": ["culture"]},
    "profile_b_data": {"bio": "famille values trust", "interests": ["musique"]},
    "model_version": "1.0.0"
  }'
```

### Vérifier que SAFIRI voit AFFINIORA

```powershell
curl http://localhost:8000/health
curl http://localhost:8001/health
```

Dans `SAFIRI/.env`, `AFFINIORA_API_URL` doit pointer vers `http://localhost:8001` (pas `http://ai-engine:8001` en mode local).

---

## Modes de lancement

| Commande | Infra | Apps | AFFINIORA |
|----------|-------|------|-----------|
| `make dev` | Docker (postgres, redis, minio) | Local | Docker |
| `make dev-docker` | Tout Docker | Docker | Optionnel dans stack |
| `make dev -SkipAffiniora` | Docker SAFIRI seul | Local | Désactivé |

Sans AFFINIORA (scores factices / fallback) :

```powershell
powershell -ExecutionPolicy Bypass -File docs\scripts\dev.ps1 -Mode local -SkipAffiniora
```

---

## Commandes utiles

```powershell
make migrate              # Migrations Alembic
make seed                 # Données de test
make fixtures-reset       # Réinitialiser le seed
make down                 # Arrêter les conteneurs Docker
make clean                # Arrêter + supprimer volumes Docker
```

Tests e2e :

```powershell
cd SAFIRI
npx playwright test
```

---

## Dépannage

Voir le guide détaillé : [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

| Problème | Piste |
|----------|-------|
| AFFINIORA ne démarre pas | `cd AFFINIORA && docker compose up --build` et lire les logs |
| Port 8001 occupé | `netstat -ano \| findstr 8001` |
| Scores IA absents | Lancer Celery (terminal 4) |
| `password authentication failed` sur Postgres | Port 5432 occupé par un autre Postgres — arrêter l'autre conteneur |
| Docker Hub inaccessible | Configurer DNS `8.8.8.8` dans Docker Desktop |
| Erreurs Next.js / React | Nettoyer `.next` et relancer (voir TROUBLESHOOTING) |

---

## Documentation complémentaire

| Document | Contenu |
|----------|---------|
| [**État d'avancement**](./ETAT_AVANCEMENT.md) | Statuts réels, solutions, compétences par feature — **v2.2** |
| [Fiches modules](./modules/README.md) | 22 modules dont channels, wallet, badges, speed dating |
| [VISION.md](./VISION.md) | Mission, naming (SAFIRI/AFFINIORA/Sarielle) |
| [SPECIFICATION_FONCTIONNELLE.md](./SPECIFICATION_FONCTIONNELLE.md) | Spec détaillée 16+ modules |
| [RECETTE.md](./RECETTE.md) | Plan de recette, scénarios |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Architecture écosystème |
| [Déploiement AWS](./infra/README.md) | Staging ECS, Terraform, scripts bootstrap/deploy |
| [Contrat IA v2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md) | UserProfileIA (dépôt AFFINIORA) |
| [SAFIRI](https://github.com/AFROMIA/SAFIRI/blob/main/docs/ARCHITECTURE.md) | Architecture app |
| [AFFINIORA](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/ARCHITECTURE.md) | Architecture IA |
| [Design system](./ux/design.md) | Charte UX |
| [Comptes de test](./COMPTES_TEST.md) | Fixtures et rôles |
| [env-profiles/](./env-profiles/) | Templates `.env` |
