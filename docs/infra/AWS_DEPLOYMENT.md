# AFROMIA — Déploiement AWS (guide complet)

> **Objectif** : mettre SAFIRI + AFFINIORA en ligne sur AWS (pay-as-you-go), avec pipeline DevOps, haute disponibilité et métriques centralisées.
>
> **Région recommandée** : `eu-west-3` (Paris) ou `eu-west-1` (Irlande) — le Terraform par défaut utilise `eu-west-1`.

---

## Ce que vous devez faire (checklist)

### Étape 0 — Outils locaux (déjà installés sur votre machine)

| Outil | Statut | Commande de vérification |
|-------|--------|--------------------------|
| AWS CLI v2 | ✅ Installé | `aws --version` |
| Terraform | ✅ Installé | `terraform --version` |
| Docker Desktop | ⚠️ À installer | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |
| Git | Requis | `git --version` |

> **Important** : redémarrez le terminal (ou Cursor) après l'installation pour que le PATH soit à jour.

### Étape 1 — Sécurité : ne jamais utiliser le compte root

Vous êtes connecté en **root** sur la console AWS. C'est acceptable pour la **configuration initiale uniquement**, puis vous devez créer un utilisateur IAM dédié.

1. Console AWS → **IAM** → **Utilisateurs** → **Créer un utilisateur**
2. Nom : `afromia-dev-agent`
3. Type d'accès : **Accès par clé d'accès** (programmatique)
4. Attacher la politique : `AdministratorAccess` *(MVP rapide)* ou la politique custom dans [`iam/afromia-dev-agent-policy.json`](./iam/afromia-dev-agent-policy.json) *(moindre privilège)*
5. **Télécharger le CSV** des clés (Access Key ID + Secret Access Key)
6. Activer **MFA** sur le compte root et sur `afromia-dev-agent`

### Étape 2 — Configurer AWS CLI sur votre machine

```powershell
cd "C:\Users\MAITRE\Documents\IronCorp technologies\AFROMIA\docs\infra\scripts"
.\configure-aws-profile.ps1
```

Ou manuellement :

```powershell
aws configure --profile afromia-dev
# AWS Access Key ID:     <votre clé>
# AWS Secret Access Key: <votre secret>
# Default region:        eu-west-1
# Default output:        json

aws sts get-caller-identity --profile afromia-dev
```

### Étape 3 — Ce que vous devez me fournir (dans le chat)

| Information | Obligatoire | Exemple |
|-------------|-------------|---------|
| Région AWS | Oui | `eu-west-1` |
| Nom d'environnement | Oui | `staging` |
| URLs GitHub SAFIRI + AFFINIORA | Oui | `github.com/org/safiri` |
| Nom de domaine (si vous en avez un) | Non | `app.afromia.com` |
| Budget mensuel max | Recommandé | `150 €/mois` |

**Ne partagez jamais** dans le chat : clés AWS, mots de passe RDS, `JWT_SECRET_KEY`, clés Stripe.

### Étape 4 — Bootstrap infrastructure (une seule fois)

```powershell
.\bootstrap-aws.ps1 -Profile afromia-dev -Environment staging
```

Ce script :
- Crée le bucket S3 `afromia-terraform-state` (état Terraform)
- Active le versioning et le chiffrement
- Initialise et applique Terraform (VPC, RDS, Redis, ECS, ALB, CloudFront, ECR, CloudWatch)
- Crée les dépôts ECR pour les images Docker

### Étape 5 — Premier déploiement applicatif

```powershell
.\deploy-staging.ps1 -Profile afromia-dev
```

Build les images Docker, les pousse sur ECR, et redéploie les services ECS.

### Étape 6 — Secrets applicatifs

Après le Terraform, renseigner les secrets dans **AWS Secrets Manager** (`afromia-staging/app-secrets`) :

| Secret | Source |
|--------|--------|
| `JWT_SECRET_KEY` | `openssl rand -hex 32` |
| `SECRET_KEY` | `openssl rand -hex 32` |
| `DATABASE_URL` | Output Terraform `rds_endpoint` |
| `REDIS_URL` | Output Terraform `redis_endpoint` |
| `STRIPE_SECRET_KEY` | Dashboard Stripe |
| `AFFINIORA_API_URL` | URL interne ALB → service ai-engine |

### Étape 7 — GitHub Actions (CI/CD automatique)

Dans chaque dépôt GitHub (SAFIRI et AFFINIORA), ajouter les secrets :

| Secret GitHub | Valeur |
|---------------|--------|
| `AWS_ACCESS_KEY_ID` | Clé de `afromia-dev-agent` |
| `AWS_SECRET_ACCESS_KEY` | Secret de `afromia-dev-agent` |

Les workflows existants (`deploy-staging.yml`) déploient automatiquement à chaque push sur `main`.

---

## Architecture cloud (résumé)

```
Internet
    │
    ▼
CloudFront (CDN + HTTPS)
    │
    ▼
ALB (Application Load Balancer)
    ├── /          → ECS safiri-frontend  (Fargate)
    ├── /api/*     → ECS safiri-backend   (Fargate)
    └── /ai/*      → ECS affiniora-ai-engine (Fargate 4-8 GB)
                          │
    ┌─────────────────────┼─────────────────────┐
    ▼                     ▼                     ▼
 RDS PostgreSQL      ElastiCache Redis       S3 (médias)
 (PostGIS+pgvector)  (cache + Celery)        (statique)
```

| Service | Technologie AWS | Scalabilité | Coût estimé staging |
|---------|-----------------|-------------|---------------------|
| Frontend | ECS Fargate (0.5 vCPU, 1 GB) | Auto-scaling 1-3 | ~15 €/mois |
| Backend API | ECS Fargate (1 vCPU, 2 GB) | Auto-scaling 1-4 | ~30 €/mois |
| Celery workers | ECS Fargate (1 vCPU, 2 GB) | Auto-scaling 0-2 | ~15 €/mois |
| AFFINIORA AI | ECS Fargate (2 vCPU, 8 GB) | Auto-scaling 1-2 | ~80 €/mois |
| Base de données | RDS db.t3.medium | Multi-AZ en prod | ~50 €/mois |
| Cache | ElastiCache cache.t3.micro | Cluster en prod | ~15 €/mois |
| CDN | CloudFront | Global | ~5 €/mois |
| **Total staging** | | | **~210 €/mois** |

> AFFINIORA est le poste le plus coûteux (modèles HuggingFace en RAM). En MVP, on peut démarrer avec 4 GB et scaler si besoin.

---

## Métriques centralisées (CloudWatch)

Tous les services envoient leurs métriques vers un **dashboard CloudWatch** unique :

- CPU / mémoire ECS par service
- Requêtes ALB (latence p50/p99, erreurs 5xx)
- Connexions RDS, espace disque
- Hits/miss Redis
- Logs applicatifs (`/ecs/afromia-staging/*`)

Accès : Console AWS → **CloudWatch** → **Tableaux de bord** → `afromia-staging-overview`

Alarmes configurées :
- CPU ECS > 80 % pendant 5 min → notification SNS
- Erreurs ALB 5xx > 10/min → notification SNS
- RDS espace libre < 20 % → notification SNS

---

## Planning « en ligne aujourd'hui »

| Heure | Action | Qui |
|-------|--------|-----|
| H+0 | Créer IAM `afromia-dev-agent` + configurer CLI | Vous |
| H+0.5 | `bootstrap-aws.ps1` (Terraform ~20 min) | Agent / vous |
| H+1 | Build + push images Docker | Agent |
| H+1.5 | Migrations DB + secrets | Agent |
| H+2 | Tests smoke (health checks) | Agent |
| H+2.5 | URL CloudFront fonctionnelle | ✅ En ligne |

---

## Documentation complémentaire

- [Architecture cloud détaillée](./ARCHITECTURE_CLOUD.md)
- [Pipeline DevOps](./DEVOPS_PIPELINE.md)
- [Politique IAM dev agent](./iam/afromia-dev-agent-policy.json)
- [Architecture écosystème](../ARCHITECTURE.md)

---

## Dépannage

```powershell
# Vérifier l'identité AWS
aws sts get-caller-identity --profile afromia-dev

# Voir les services ECS
aws ecs list-services --cluster afromia-staging --profile afromia-dev

# Logs backend en temps réel
aws logs tail /ecs/afromia-staging/safiri-backend --follow --profile afromia-dev

# Forcer un redéploiement
aws ecs update-service --cluster afromia-staging --service safiri-backend --force-new-deployment --profile afromia-dev
```
