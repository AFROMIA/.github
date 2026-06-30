# Module 18 — Infra & DevOps

**Statut** : 🚧 En cours (local 🟡 · AWS staging 🟡)  
**Spec** : NFR-01 à NFR-14

---

## Vision

Stack locale fiable + déploiement AWS staging (ECS Fargate, RDS, Redis, CloudFront) avec pipeline CI/CD depuis SAFIRI et AFFINIORA.

## État réel

| Composant | État |
|-----------|------|
| `make bootstrap` / `make dev-split` | 🟡 |
| Docker Postgres, Redis, MinIO (local) | ✅ |
| AFFINIORA Docker (:8001) | 🟡 |
| Celery worker | ❌ (manuel) |
| Terraform AWS (79 ressources) | 🟡 plan OK, apply bloqué IAM |
| Scripts déploiement staging | ✅ |
| ECR + ECS deploy script | ✅ |
| Secrets Manager + migrations ECS | ✅ (scripts) |
| GitHub Actions deploy-staging | 🟡 (secrets à configurer) |
| SMTP / OAuth / Stripe / VAPID | ❌ |

## Solution proposée

1. Attacher `AdministratorAccess` à `afromia-dev-agent` → [IAM_BLOCKER.md](../infra/IAM_BLOCKER.md)
2. `bootstrap-aws.ps1` → `deploy-staging.ps1` → `setup-secrets.ps1` → `run-migrations.ps1`
3. `setup-github-secrets.ps1` pour CI automatique SAFIRI + AFFINIORA
4. Local : `make dev-split` par défaut + Celery documenté

## Compétences requises

- **AWS** : IAM, VPC, ECS Fargate, RDS, ElastiCache, CloudFront, Secrets Manager
- **Terraform** : modules, state S3, tfvars sensibles hors Git
- **DevOps** : Docker multi-stage, ECR, GitHub Actions
- **SRE** : CloudWatch dashboards, alarmes SNS

## Documentation

- [Index infra](../infra/README.md)
- [AWS_DEPLOYMENT.md](../infra/AWS_DEPLOYMENT.md)
- [DEVOPS_PIPELINE.md](../infra/DEVOPS_PIPELINE.md)

## Actions prioritaires (P0)

1. Débloquer IAM et appliquer Terraform staging
2. Premier deploy ECR + smoke health checks
3. Secrets applicatifs + migrations en staging
4. `make dev-split` fiable en local
