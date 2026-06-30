# GitHub Branch Protection — configuration manuelle

Les règles de protection de branche ne sont pas versionnables dans le dépôt. Appliquez ces réglages sur **chaque repo** (SAFIRI et AFFINIORA) via GitHub :

## Étapes (Settings → Branches → Branch protection rules → `main`)

1. **Require a pull request before merging**
   - Required approvals : 1
   - Dismiss stale reviews : activé

2. **Require status checks to pass before merging**
   - Require branches to be up to date : activé
   - Status checks requis :

### SAFIRI

| Check | Workflow / job |
|-------|----------------|
| `backend-lint` | SAFIRI CI |
| `backend-unit-coverage` | SAFIRI CI |
| `backend-integration-coverage` | SAFIRI CI |
| `frontend-lint` | SAFIRI CI |
| `frontend-unit-coverage` | SAFIRI CI |
| `e2e-critical-paths` | SAFIRI CI |
| `quality-gate` | SAFIRI CI |

### AFFINIORA

| Check | Workflow / job |
|-------|----------------|
| `ai-engine-lint` | AFFINIORA CI |
| `ai-engine-unit-coverage` | AFFINIORA CI |
| `ai-engine-integration-coverage` | AFFINIORA CI |
| `quality-gate` | AFFINIORA CI |

3. **Do not allow bypassing the above settings** (admins inclus en production)

4. **Restrict who can push to matching branches** — optionnel, équipe core uniquement

## Déploiement staging

Le workflow `deploy-staging.yml` appelle `ci.yml` via `workflow_call` et ne déploie que si `quality-gate` est vert.

## Script gh CLI (optionnel)

```powershell
# SAFIRI — après un premier run CI sur main pour enregistrer les checks
gh api repos/:owner/:repo/branches/main/protection -X PUT -f required_status_checks[strict]=true `
  -f required_pull_request_reviews[required_approving_review_count]=1 `
  -f enforce_admins=true `
  -f restrictions=null
```

Remplacez `:owner/:repo` par l'organisation et le nom du dépôt.
