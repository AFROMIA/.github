# AFROMIA — Infrastructure & déploiement AWS

Index des guides et scripts pour mettre **SAFIRI + AFFINIORA** en ligne sur AWS (staging puis production).

## Guides

| Document | Description |
|----------|-------------|
| [**AWS_DEPLOYMENT.md**](./AWS_DEPLOYMENT.md) | Checklist complète : IAM, Terraform, ECS, secrets, CI/CD |
| [**ARCHITECTURE_CLOUD.md**](./ARCHITECTURE_CLOUD.md) | Schéma VPC, ALB, CloudFront, RDS, Redis |
| [**DEVOPS_PIPELINE.md**](./DEVOPS_PIPELINE.md) | Workflows GitHub Actions SAFIRI + AFFINIORA |
| [**GITHUB_BRANCH_PROTECTION.md**](./GITHUB_BRANCH_PROTECTION.md) | Règles PR + status checks (config org GitHub) |
| [**IAM_BLOCKER.md**](./IAM_BLOCKER.md) | Déblocage permissions `afromia-dev-agent` (si Terraform bloqué) |

## Scripts (`scripts/`)

| Script | Rôle |
|--------|------|
| [`configure-aws-profile.ps1`](./scripts/configure-aws-profile.ps1) | Configure le profil CLI `afromia-dev` |
| [`setup-access-keys.ps1`](./scripts/setup-access-keys.ps1) | Import clés depuis CSV IAM |
| [`bootstrap-aws.ps1`](./scripts/bootstrap-aws.ps1) | S3 state + `terraform init/apply` (79 ressources) |
| [`fix-iam-permissions.ps1`](./scripts/fix-iam-permissions.ps1) | Instructions console IAM (AdministratorAccess) |
| [`resume-deploy.ps1`](./scripts/resume-deploy.ps1) | Reprend Terraform après correction IAM |
| [`deploy-staging.ps1`](./scripts/deploy-staging.ps1) | Build Docker → push ECR → redéploiement ECS |
| [`setup-secrets.ps1`](./scripts/setup-secrets.ps1) | Génère secrets dans AWS Secrets Manager |
| [`run-migrations.ps1`](./scripts/run-migrations.ps1) | Alembic via ECS run-task (one-shot) |
| [`setup-github-secrets.ps1`](./scripts/setup-github-secrets.ps1) | Secrets AWS dans repos SAFIRI + AFFINIORA |

## Terraform (`terraform/aws/`)

| Fichier | Ressource |
|---------|-----------|
| `main.tf` | Provider, backend S3, variables |
| `networking.tf` | VPC, subnets, ALB, CloudFront |
| `ecs.tf` | Cluster Fargate, services, task definitions |
| `ecr.tf` | Registres images Docker |
| `iam.tf` | Rôles ECS task / execution |
| `monitoring.tf` | CloudWatch dashboard + alarmes SNS |
| `terraform.tfvars.example` | Template variables (copier → `terraform.tfvars`, **non versionné**) |

## Ordre d'exécution (staging)

```powershell
cd docs/infra/scripts
.\configure-aws-profile.ps1
.\bootstrap-aws.ps1 -Profile afromia-dev -Environment staging
.\deploy-staging.ps1 -Profile afromia-dev
.\setup-secrets.ps1 -Profile afromia-dev -Environment staging
.\run-migrations.ps1 -Profile afromia-dev -Environment staging
.\setup-github-secrets.ps1 -SafiriRepo "AFROMIA/SAFIRI" -AffinioraRepo "AFROMIA/AFFINIORA"
```

Si permissions IAM insuffisantes → voir [IAM_BLOCKER.md](./IAM_BLOCKER.md) puis `.\resume-deploy.ps1`.

## Dépôts applicatifs

| Dépôt | CI/CD | Infra locale |
|-------|-------|--------------|
| [SAFIRI](https://github.com/AFROMIA/SAFIRI) | `.github/workflows/deploy-staging.yml` | `docker-compose.yml` |
| [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) | `.github/workflows/` | `docker-compose.yml` |
| [`.github`](https://github.com/AFROMIA/.github) | — | Docs + scripts (ce dossier) |
