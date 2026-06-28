# Module 15 — Administration & modération

**Statut** : 🟡 Partiel  
**Spec** : ADM-01 à ADM-10

---

## Vision

Backoffice pour Sarielle (CEO) : KPI, utilisateurs, signalements, vérif vidéo, utilisateurs en ligne, CMS, test Affiniora, messages ciblés.

## État réel

| Composant | État |
|-----------|------|
| Shell `/admin` + RBAC | ✅ |
| Dashboard KPI | 🟡 |
| Gestion utilisateurs / rôles | ✅ |
| Signalements workflow | 🟡 |
| File vérif vidéo | 🟡 (dépend Celery) |
| Utilisateurs en ligne + message direct | 🟡 |
| Panel test Affiniora | 🟡 (dépend AFFINIORA up) |
| CMS homepage admin | ✅ |

## Recette

- Scénarios R-P0-07, R-P0-08 — voir [RECETTE.md](../RECETTE.md)
- Tests RBAC pytest partiels

## Actions prioritaires

1. Valider `/admin/online-users` sans erreur 500/CORS
2. Workflow signalement complet (report → résolution)
3. KPI reflètent données réelles (pas mock)
4. Recette message direct admin → user
