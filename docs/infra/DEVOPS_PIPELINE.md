# AFROMIA — Pipeline DevOps

## Vue d'ensemble

L'écosystème AFROMIA utilise **deux dépôts Git indépendants** avec des pipelines CI/CD séparés mais coordonnés sur la même infrastructure AWS.

```
┌─────────────────┐     push main      ┌──────────────────┐
│  SAFIRI (GitHub)│ ─────────────────► │ GitHub Actions   │
│  frontend+backend│                    │ ci.yml           │
└─────────────────┘                    │ deploy-staging   │
                                       └────────┬─────────┘
                                                │
┌─────────────────┐     push main               ▼
│ AFFINIORA       │ ─────────────────►   ┌──────────────┐
│ ai-engine       │                    │  Amazon ECR  │
└─────────────────┘                    └──────┬───────┘
                                              │
                                              ▼
                                       ┌──────────────┐
                                       │ ECS Fargate  │
                                       │ afromia-staging│
                                       └──────────────┘
```

## Pipeline DevOps (gates qualité)

Voir [GITHUB_BRANCH_PROTECTION.md](./GITHUB_BRANCH_PROTECTION.md) pour la configuration des branch protection rules.

### Gates obligatoires avant merge / deploy

| Gate | Seuil |
|------|-------|
| Tests unitaires backend | 90 % couverture (`app.core` + `app.domain`) |
| Tests intégration backend | 90 % couverture (infra + auth API) |
| Tests unitaires frontend | 90 % couverture (`src/lib`) |
| E2E parcours critiques | 80 % du catalogue (`docs/E2E_CRITICAL_PATHS.md`) |

Le déploiement staging (`deploy-staging.yml`) appelle `ci.yml` via `workflow_call` et ne s'exécute qu'après `quality-gate`.

## Dépôts et workflows

### SAFIRI (`SAFIRI/.github/workflows/`)

| Workflow | Déclencheur | Actions |
|----------|-------------|---------|
| `ci.yml` | PR + push | Lint, tests, build Docker |
| `deploy-staging.yml` | push `main` | Build → ECR → ECS update |
| `deploy-production.yml` | tag `v*` | Build → ECR prod → ECS prod |

**Images produites :**
- `safiri-backend:staging` — API FastAPI (port 8000)
- `safiri-frontend:staging` — Next.js 15 (port 3000)

**Services ECS :**
- `safiri-backend` — API REST + WebSocket
- `safiri-frontend` — Interface utilisateur
- `safiri-celery-worker` — Tâches async (matching, notifications)
- `safiri-celery-beat` — Planificateur cron

### AFFINIORA (`AFFINIORA/.github/workflows/`)

| Workflow | Déclencheur | Actions |
|----------|-------------|---------|
| `ci.yml` | PR + push | pytest, build Docker |
| `deploy-staging.yml` | push `main` | Build → ECR → ECS update |
| `deploy-production.yml` | tag `v*` | Build → ECR prod → ECS prod |

**Image produite :**
- `affiniora-ai-engine:staging` — Moteur IA HuggingFace (port 8001, 4-8 GB RAM)

## Flux de déploiement

### Staging (automatique)

1. Développeur push sur `main`
2. GitHub Actions checkout le code
3. Authentification AWS via secrets `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
4. Login ECR (`aws-actions/amazon-ecr-login`)
5. `docker build` + `docker push` vers ECR
6. `aws ecs update-service --force-new-deployment`
7. ECS fait un rolling update (zéro downtime)

### Production (manuel via tag)

```bash
git tag v1.0.0
git push origin v1.0.0
```

Le workflow `deploy-production.yml` se déclenche sur les tags `v*`.

## Infrastructure as Code (Terraform)

```
docs/infra/terraform/aws/
├── main.tf          # Provider, VPC, RDS, Redis, S3, ALB, CloudFront
├── networking.tf    # Route tables, NAT, security groups
├── ecr.tf           # Registres Docker
├── ecs.tf           # Cluster, services, task definitions, auto-scaling
├── iam.tf           # Rôles ECS task execution + task role
├── monitoring.tf    # CloudWatch dashboard + alarmes SNS
└── terraform.tfvars.example
```

**État Terraform** : bucket S3 `afromia-terraform-state`, clé `afromia/terraform.tfstate`.

```powershell
cd docs/infra/terraform/aws
terraform init
terraform plan -var="db_password=<secret>"
terraform apply -var="db_password=<secret>"
```

## Variables d'environnement par environnement

| Variable | Staging | Production |
|----------|---------|------------|
| `ENVIRONMENT` | staging | production |
| `DEBUG_ENABLED` | true | false |
| `DATABASE_SSL` | true | true |
| `AFFINIORA_API_URL` | http://affiniora-ai-engine:8001 | idem (réseau interne VPC) |
| `NEXT_PUBLIC_API_URL` | https://<cloudfront>/api | https://app.afromia.com/api |

Les secrets sensibles sont dans **AWS Secrets Manager**, injectés dans les task definitions ECS.

## Communication inter-services

```
safiri-backend ──REST──► affiniora-ai-engine:8001
     │                        │
     │ PostgreSQL             │ Redis (cache modèles)
     ▼                        ▼
   RDS                    ElastiCache
     │
     │ Redis (pub/sub chat, Celery)
     ▼
 ElastiCache
```

- SAFIRI appelle AFFINIORA via `AFFINIORA_API_URL` (réseau privé ECS, pas d'exposition publique)
- AFFINIORA n'a pas d'accès direct à la base SAFIRI (contrat REST uniquement)

## Rollback

```powershell
# Revenir à la révision précédente d'un service ECS
aws ecs describe-services --cluster afromia-staging --services safiri-backend --profile afromia-dev
aws ecs update-service --cluster afromia-staging --service safiri-backend --task-definition safiri-backend:<revision-precedente> --profile afromia-dev
```

## Monitoring du pipeline

- **GitHub Actions** : onglet Actions de chaque dépôt
- **ECS Events** : Console AWS → ECS → Cluster → Events
- **CloudWatch** : dashboard `afromia-staging-overview`
- **Alertes SNS** : email configuré lors du bootstrap
