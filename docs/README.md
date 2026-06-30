# AFROMIA — Guide développeur

Documentation centrale de l'écosystème **SAFIRI** + **AFFINIORA**, hébergée sur le dépôt informationnel [github.com/AFROMIA/.github](https://github.com/AFROMIA/.github).

> **Principe** : toute la doc, les scripts d'orchestration et les guides de déploiement vivent sur Git — aucun chemin ni secret ne dépend d'une machine physique. Il suffit des accès GitHub + AWS (si déploiement).

| Produit | Dépôt | Interface dev |
|---------|-------|---------------|
| **SAFIRI** | [AFROMIA/SAFIRI](https://github.com/AFROMIA/SAFIRI) | http://localhost:3000 |
| **AFFINIORA** | [AFROMIA/AFFINIORA](https://github.com/AFROMIA/AFFINIORA) | http://localhost:8001/docs |
| **Docs & infra** | [AFROMIA/.github](https://github.com/AFROMIA/.github) | Ce guide |

Les deux services applicatifs communiquent **uniquement par API REST**. SAFIRI appelle AFFINIORA via `AFFINIORA_API_URL`.

---

## Onboarding — nouveau développeur

### 1. Accès requis

| Accès | Pour quoi | Qui accorde |
|-------|-----------|-------------|
| GitHub org [AFROMIA](https://github.com/AFROMIA) | Clone SAFIRI, AFFINIORA, `.github` | Admin org |
| (Optionnel) AWS `afromia-dev-agent` | Déploiement staging | Admin infra |
| (Optionnel) Stripe/Campay sandbox | Paiements | PO / Lead Dev |

### 2. Cloner les dépôts (structure recommandée)

```bash
mkdir afromia && cd afromia

git clone https://github.com/AFROMIA/.github.git
git clone https://github.com/AFROMIA/SAFIRI.git
git clone https://github.com/AFROMIA/AFFINIORA.git
```

```
afromia/
├── .github/      # Docs, scripts dev, Terraform, guides AWS
├── SAFIRI/       # App Next.js + FastAPI
└── AFFINIORA/    # Moteur IA
```

Les scripts d'orchestration sont dans `.github/docs/scripts/` et supposent **SAFIRI** et **AFFINIORA** en dossiers frères.

### 3. Travailler sur une partie du projet

| Périmètre | Dépôt | Doc de référence |
|-----------|-------|------------------|
| Frontend / UX | SAFIRI | [Fiches modules](./modules/README.md) · [ETAT_AVANCEMENT](./ETAT_AVANCEMENT.md) |
| Backend API | SAFIRI | [SAFIRI docs](https://github.com/AFROMIA/SAFIRI/tree/main/docs) |
| Moteur IA / Sarielle | AFFINIORA | [CONTRACT_V2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md) |
| Infra / déploiement | `.github` | [infra/README.md](./infra/README.md) |
| Vision / spec produit | `.github` | [VISION](./VISION.md) · [SPEC](./SPECIFICATION_FONCTIONNELLE.md) |

Chaque module (01–22) indique **état réel**, **solution proposée** et **compétences requises** dans [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md).

---

## Prérequis locaux

- **Docker Desktop** (Postgres, Redis, MinIO, AFFINIORA)
- **Node.js ≥ 20**
- **Python ≥ 3.12**
- **Git** + **Make** (optionnel ; PowerShell suffit sous Windows)

Pour le **déploiement AWS** : AWS CLI v2, Terraform ≥ 1.5, Docker (build images). Voir [AWS_DEPLOYMENT.md](./infra/AWS_DEPLOYMENT.md).

---

## Installation (première fois)

Depuis le dossier parent contenant les trois dépôts :

```powershell
cd .github
make bootstrap      # npm SAFIRI + pip backend
make env-local      # SAFIRI/.env + AFFINIORA/.env (chemins relatifs)
```

Variables essentielles dans `SAFIRI/.env` :

```env
AFFINIORA_API_URL=http://localhost:8001
DATABASE_URL=postgresql+asyncpg://afromia:afromia@localhost:5432/afromia
REDIS_URL=redis://localhost:6379/0
S3_ENDPOINT_URL=http://localhost:9000
```

AFFINIORA tourne en **Docker** : pas besoin d'installer PyTorch en local.

---

## Démarrage rapide

### Recommandé — multi-terminaux (`make dev-split`)

```powershell
cd .github
make dev-split
```

Lance infra Docker, backend `:8000`, frontend `:3000`, Affiniora `:8001`, Celery — voir [start.md](../start.md).

### Un seul terminal

```powershell
cd .github
make dev
```

Équivalent : `docs\start.ps1 -Mode local` ou `docs\start.bat`

| Étape | Quoi |
|-------|------|
| 1 | Docker : Postgres, Redis, MinIO |
| 2 | Docker : AFFINIORA ai-engine `:8001` |
| 3 | Migrations Alembic (012–021) + seed |
| 4 | Backend + Frontend locaux |

**Premier build AFFINIORA** : PyTorch CPU dans l'image (~5–15 min).

### URLs locales

| Service | URL |
|---------|-----|
| SAFIRI (app) | http://localhost:3000 |
| API SAFIRI | http://localhost:8000/docs |
| AFFINIORA | http://localhost:8001/docs |
| MinIO | http://localhost:9001 (`minioadmin` / `minioadmin`) |

---

## Déploiement AWS (staging)

Documentation complète : [infra/README.md](./infra/README.md)

```powershell
cd .github/docs/infra/scripts
.\configure-aws-profile.ps1
.\bootstrap-aws.ps1 -Profile afromia-dev -Environment staging
.\deploy-staging.ps1 -Profile afromia-dev
.\setup-secrets.ps1 -Profile afromia-dev
.\run-migrations.ps1 -Profile afromia-dev
.\setup-github-secrets.ps1 -SafiriRepo "AFROMIA/SAFIRI" -AffinioraRepo "AFROMIA/AFFINIORA"
```

**Bloqueur connu** : permissions IAM insuffisantes sur `afromia-dev-agent` → [IAM_BLOCKER.md](./infra/IAM_BLOCKER.md).

Après déploiement : CI/CD automatique via GitHub Actions sur push `main` (secrets AWS requis dans chaque dépôt applicatif).

---

## Fonctionnalités & parcours type

1. Inscription → onboarding → quiz → personnalité (AFFINIORA v2)
2. Discover (scores) → match → chat temps réel
3. Channels créateur · wallet Safir · premium checkout
4. Admin · debug panel IA Lab

Comptes seed : [COMPTES_TEST.md](./COMPTES_TEST.md) — `make seed` depuis `.github/`.

---

## AFFINIORA — endpoints clés

| Route | Version |
|-------|---------|
| `/v1/score/compatibility` | v1 |
| `/v1/analyze/profile-full` | v2 |
| `/v1/coaching/regenerate` | v2 |
| `/v1/chat/sarielle` | v2 |

Contrat : [AFFINIORA/docs/CONTRACT_V2.md](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md)

---

## Commandes utiles

```powershell
make migrate
make seed
make down
make dev-clean          # purge cache Next.js
```

Tests :

```powershell
cd SAFIRI && npx playwright test
cd SAFIRI/apps/backend && python -m pytest tests/ -v
cd AFFINIORA/services/ai-engine && python -m pytest tests/ -v
```

---

## Dépannage

[Voir TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

| Problème | Piste |
|----------|-------|
| AFFINIORA down | `make dev-affiniora` ou terminal 4 de `dev-split` |
| Scores IA absents | Lancer Celery |
| Terraform bloqué | [IAM_BLOCKER.md](./infra/IAM_BLOCKER.md) |
| Erreurs Next.js | `make dev-clean` |

---

## Documentation complémentaire

| Document | Contenu |
|----------|---------|
| [**État d'avancement**](./ETAT_AVANCEMENT.md) | Statuts, solutions, compétences — **v2.3** |
| [Fiches modules](./modules/README.md) | 22 modules |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Écosystème 3 dépôts + cloud |
| [VISION.md](./VISION.md) · [SPEC](./SPECIFICATION_FONCTIONNELLE.md) | Produit |
| [RECETTE.md](./RECETTE.md) | Tests manuels + staging AWS |
| [PLANNING_MVP.md](./PLANNING_MVP.md) | Sprints jusqu'au 15 août 2026 |
| [Déploiement AWS](./infra/README.md) | Terraform, ECS, scripts |
| [env-profiles/](./env-profiles/) | Templates `.env` |
