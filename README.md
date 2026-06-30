# AFROMIA — Dépôt informationnel

Documentation, scripts d'orchestration et état d'avancement de l'écosystème **SAFIRI** + **AFFINIORA**.

> Le README affiché sur [github.com/AFROMIA](https://github.com/AFROMIA) est dans [`profile/README.md`](./profile/README.md).

## Dépôts applicatifs

| Dépôt | Rôle | Lien |
|-------|------|------|
| [SAFIRI](https://github.com/AFROMIA/SAFIRI) | App rencontre (Next.js + FastAPI) | Code frontend/backend |
| [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) | Moteur IA (scoring, Sarielle v2) | [Contrat API v2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md) |
| **Ce dépôt** (`.github`) | Docs, scripts dev, état projet | Vous êtes ici |

## Documentation essentielle

| Document | Description |
|----------|-------------|
| [**État d'avancement**](./docs/ETAT_AVANCEMENT.md) | Vérité technique : statuts, bloqueurs, **solutions & compétences** |
| [Fiches modules](./docs/modules/README.md) | 22 modules — vision, état, actions |
| [Guide développeur](./docs/README.md) | Installation, URLs, utilisation SAFIRI/AFFINIORA |
| [Démarrage rapide](./start.md) | `make dev`, `make dev-split`, dépannage |
| [Architecture](./docs/ARCHITECTURE.md) | Écosystème, flux données, nouveautés 2026 |
| [Vision](./docs/VISION.md) | Mission, naming, piliers produit |
| [Spécification](./docs/SPECIFICATION_FONCTIONNELLE.md) | Exigences fonctionnelles détaillées |
| [Recette](./docs/RECETTE.md) | Scénarios de test manuels |
| [Comptes test](./docs/COMPTES_TEST.md) | Fixtures seed |
| [Dépannage](./docs/TROUBLESHOOTING.md) | Problèmes fréquents |

## Infrastructure & déploiement AWS

| Document | Description |
|----------|-------------|
| [**Index infra**](./docs/infra/README.md) | Scripts, Terraform, ordre d'exécution staging |
| [AWS Deployment](./docs/infra/AWS_DEPLOYMENT.md) | Guide complet déploiement cloud |
| [IAM Blocker](./docs/infra/IAM_BLOCKER.md) | Déblocage permissions si Terraform échoue |
| [DevOps Pipeline](./docs/infra/DEVOPS_PIPELINE.md) | CI/CD GitHub Actions → ECR → ECS |
| [Architecture cloud](./docs/infra/ARCHITECTURE_CLOUD.md) | VPC, ALB, CloudFront, RDS, Redis |
| [Terraform](./docs/infra/terraform/aws/) | Modules ECS/ECR/Networking (référence) |

### Scripts déploiement (`docs/infra/scripts/`)

| Script | Usage |
|--------|-------|
| `bootstrap-aws.ps1` | Terraform init + apply (infra staging) |
| `deploy-staging.ps1` | Build images → ECR → ECS |
| `setup-secrets.ps1` | Secrets Manager (`JWT`, DB, Redis…) |
| `run-migrations.ps1` | Migrations Alembic via ECS |
| `resume-deploy.ps1` | Reprend après fix IAM |
| `setup-github-secrets.ps1` | Secrets AWS dans SAFIRI + AFFINIORA |
| `configure-aws-profile.ps1` | Profil CLI `afromia-dev` |

> **Ne jamais committer** : `terraform.tfvars`, `*.tfstate`, clés CSV IAM.

## Scripts de développement

Orchestration multi-dépôts (cloner SAFIRI + AFFINIORA à côté de ce repo) :

```
docs/scripts/
├── bootstrap.ps1 / .sh    # Dépendances npm + pip
├── setup-env.ps1 / .sh    # Profils .env (local, docker, supabase)
├── dev.ps1 / .sh          # Lance infra + apps
├── start-split.ps1        # Grille 4 terminaux Windows
├── affiniora.ps1          # Service IA Docker
├── celery.ps1             # Worker async
└── migrate.ps1            # Alembic
```

Raccourcis racine : `start.bat`, `start-split.bat`, `start-celery.bat`, `start-affiniora.bat`, `Makefile`.

## Fonctionnalités récentes (juin 2026)

| Feature | Module |
|---------|--------|
| Contrat IA v2 / UserProfileIA | [05-affiniora](./docs/modules/05-affiniora.md) |
| Channels créateur | [19-channels-createur](./docs/modules/19-channels-createur.md) |
| Wallet Safir & Campay | [20-wallet-safir](./docs/modules/20-wallet-safir.md) |
| Badges & intentions i18n | [21-badges-intentions](./docs/modules/21-badges-intentions.md) |
| Speed dating LiveKit | [22-speed-dating](./docs/modules/22-speed-dating.md) |
| Premium checkout Stripe | [09-premium-paiements](./docs/modules/09-premium-paiements.md) |
| Debug panel IA Lab | [05-affiniora](./docs/modules/05-affiniora.md) |

## Structure locale recommandée

```
votre-workspace/
├── SAFIRI/          # git clone AFROMIA/SAFIRI
├── AFFINIORA/       # git clone AFROMIA/AFFINIORA
└── .github/         # ce dépôt (docs + scripts)
```

## License

Proprietary — AFROMIA Technologies
