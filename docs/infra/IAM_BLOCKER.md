# AFROMIA — Deblocage permissions IAM (ACTION REQUISE)

## Probleme detecte

L utilisateur `afromia-dev-agent` peut **lire** AWS (EC2, ECS, ECR) mais **ne peut pas creer** de ressources :

| Action bloquee | Erreur |
|----------------|--------|
| `ec2:CreateVpc` | UnauthorizedOperation |
| `s3:CreateBucket` | AccessDenied |
| `ecs:CreateCluster` | AccessDeniedException |
| `iam:CreateRole` | AccessDenied |
| `sns:CreateTopic` | AuthorizationError |

Le deploiement Terraform (79 ressources) est **pret** mais bloque par les permissions IAM.

## Solution (2 minutes, compte ROOT)

1. Connectez-vous en **root** : https://577239834825.signin.aws.amazon.com/console
2. **IAM** > **Utilisateurs** > **afromia-dev-agent**
3. **Autorisations** > **Ajouter des autorisations** > **Attacher directement des politiques**
4. Selectionnez : **AdministratorAccess**
5. **Ajouter des autorisations**

Optionnel (bucket etat Terraform) :
6. **S3** > **Creer un bucket** > `afromia-577239834825-terraform-state` (region eu-west-1)

## Relancer le deploiement

Une fois AdministratorAccess attache, dites **"permissions OK"** ou relancez :

```powershell
cd "C:\Users\MAITRE\Documents\IronCorp technologies\AFROMIA\docs\infra\terraform\aws"
$env:AWS_PROFILE = "afromia-dev"
terraform apply -auto-approve tfplan
```

Puis :

```powershell
cd ..\scripts
.\deploy-staging.ps1 -Profile afromia-dev
.\setup-secrets.ps1 -Profile afromia-dev
.\run-migrations.ps1 -Profile afromia-dev
```

## Etat actuel (deja fait)

- Profil AWS CLI `afromia-dev` configure
- Terraform init + plan OK (79 ressources)
- Images Docker en cours de build localement
- Scripts : bootstrap, deploy, migrations, secrets, github-secrets
- Docker Desktop operationnel
