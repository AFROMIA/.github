# AFROMIA — Architecture écosystème

> **Démarrage** : [Guide développeur](./README.md) · **Cloud** : [ARCHITECTURE_CLOUD](./infra/ARCHITECTURE_CLOUD.md)

**Version** : 2.1 · **Date** : 29 juin 2026

---

## Organisation des dépôts Git

L'écosystème est réparti sur **trois dépôts GitHub indépendants** — source de vérité en ligne, travail distribué possible par équipe :

| Dépôt | Rôle | Contenu principal |
|-------|------|-------------------|
| [AFROMIA/.github](https://github.com/AFROMIA/.github) | **Informationnel** | Docs produit, scripts dev, Terraform AWS, recette, planning |
| [AFROMIA/SAFIRI](https://github.com/AFROMIA/SAFIRI) | **Application** | Next.js, FastAPI, packages, CI/CD, Docker |
| [AFROMIA/AFFINIORA](https://github.com/AFROMIA/AFFINIORA) | **IA** | ai-engine, Sarielle v2, contrat API, CI/CD |

```
┌─────────────────────────────────────────────────────────────┐
│              AFROMIA/.github (docs + infra)                 │
│   ETAT_AVANCEMENT · modules · scripts · Terraform AWS       │
└──────────────────────────┬──────────────────────────────────┘
                           │ orchestration locale / doc
         ┌─────────────────┴─────────────────┐
         ▼                                   ▼
┌─────────────────┐                 ┌─────────────────┐
│     SAFIRI      │    REST API     │    AFFINIORA    │
│  frontend+API   │◄───────────────►│   ai-engine     │
│  + Celery       │                 │   Sarielle v2   │
└────────┬────────┘                 └────────┬────────┘
         │                                   │
         └───────────────┬───────────────────┘
                         ▼
              AWS ECS Fargate (staging/prod)
              RDS · Redis · S3 · CloudFront · ALB
```

**Principe** : pas de dépendance de code entre SAFIRI et AFFINIORA — uniquement **REST** (+ WebSocket dans SAFIRI pour le temps réel).

---

## SAFIRI

Monorepo npm (Turborepo) :

```
SAFIRI/
├── apps/frontend/     # Next.js 15 PWA
├── apps/backend/      # FastAPI, Alembic, WebSockets, Celery
├── packages/          # shared-types, ui, config
├── infra/             # docker-compose, K8s, GitHub Actions
└── docs/
```

**Nouveautés juin 2026** : channels, wallet Safir, badges, intentions i18n, speed dating, profile IA v2, debug IaLab.

---

## AFFINIORA

Microservice IA HuggingFace + routeur LLM :

```
AFFINIORA/
├── services/ai-engine/
└── docs/CONTRACT_V2.md
```

**Contrat v2** : `UserProfileIA`, `profile-full`, coaching, Sarielle avec RAG.

---

## Environnements

| Env | Compute | DB | Doc |
|-----|---------|-----|-----|
| **Local** | Docker + processus locaux | Postgres/Redis/MinIO Docker | [README](./README.md) |
| **Staging AWS** | ECS Fargate `afromia-staging` | RDS + ElastiCache | [AWS_DEPLOYMENT](./infra/AWS_DEPLOYMENT.md) |
| **Production** | ECS (phase S8) | RDS Multi-AZ | [PLANNING_MVP](./PLANNING_MVP.md) |

### Pipeline déploiement staging (juin 2026)

```
Terraform (bootstrap-aws.ps1)
  → VPC, ALB, CloudFront, RDS, Redis, ECR, ECS
deploy-staging.ps1
  → Build Docker → push ECR → rolling update ECS
setup-secrets.ps1 + run-migrations.ps1
  → Secrets Manager + Alembic ECS task
GitHub Actions (SAFIRI + AFFINIORA)
  → CI/CD automatique sur push main
```

État actuel : Terraform **planifié** (79 ressources) ; apply **bloqué IAM** — voir [IAM_BLOCKER.md](./infra/IAM_BLOCKER.md).

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Backend | FastAPI, SQLAlchemy 2 async, Alembic |
| Frontend | Next.js 15, Zustand, TanStack Query, next-intl |
| IA | HuggingFace, routeur cloud/local, pgvector RAG |
| DB | PostgreSQL 16 + PostGIS + pgvector |
| Cache / queues | Redis 7, Celery |
| Cloud | AWS ECS Fargate, Terraform, CloudWatch |
| CI | GitHub Actions → ECR → ECS |

---

## Flux de données (résumé)

1. **Discover** → SAFIRI backend → AFFINIORA score (cache Redis 24h)
2. **Analyse profil** → `UserProfileIA` + RAG pgvector → AFFINIORA `profile-full` → Celery
3. **Match** → WebSocket chat (Redis Pub/Sub), typing, acks
4. **Channels** → offerings, abonnements, engagement, inquiries
5. **Wallet** → ledger Safir, Campay/Stripe
6. **Premium** → Stripe webhook → `ia_gating` (cloud LLM)

---

## Fonctionnalités par couche (2026)

### Temps réel & social

| Feature | Frontend | Backend |
|---------|----------|---------|
| Chat optimiste | WebSocket hooks | `chat_ws.py` |
| Discover Hub | `DiscoverFloatingHub` | discovery helpers |
| Channels | `/channels`, studio | `channels.py` 012–021 |
| Speed dating | `/speed-dating` | orchestrator + LiveKit |

### IA v2

| Composant | Rôle |
|-----------|------|
| `UserProfileIA` | Agrégat canonique cross-repo |
| `RagService` | Recherche hybride SAFIRI |
| `ia_gating.py` | Limites free/premium |
| Routeur LLM | Cloud (premium) / Qwen local |

---

## Outils partagés (dépôt `.github`)

| Chemin | Rôle |
|--------|------|
| `docs/scripts/` | Bootstrap, dev, celery, affiniora, start-split |
| `docs/env-profiles/` | Templates `.env` local/docker/supabase |
| `docs/infra/terraform/aws/` | Infrastructure AWS référence |
| `docs/infra/scripts/` | bootstrap-aws, deploy-staging, secrets, migrations |
| `docs/modules/` | 22 fiches module |
| `Makefile` | Orchestration racine |

---

## Documentation

| Document | Lien |
|----------|------|
| Guide dev | [README.md](./README.md) |
| État réel | [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md) |
| Cloud AWS | [infra/ARCHITECTURE_CLOUD.md](./infra/ARCHITECTURE_CLOUD.md) |
| SAFIRI | [github.com/AFROMIA/SAFIRI](https://github.com/AFROMIA/SAFIRI) |
| AFFINIORA | [github.com/AFROMIA/AFFINIORA](https://github.com/AFROMIA/AFFINIORA) |
