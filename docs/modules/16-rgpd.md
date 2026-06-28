# Module 16 — RGPD & conformité

**Statut** : 🟡 Partiel  
**Spec** : GDPR-01 à GDPR-03

---

## Vision

Export JSON complet des données utilisateur, suppression compte (soft delete + purge Celery 30j), pages légales publiées.

## État réel

| Composant | État |
|-----------|------|
| `GET /gdpr/export` | 🟡 |
| Suppression compte + purge planifiée | 🟡 |
| Pages `/gdpr/export`, `/gdpr/delete` | ✅ |
| Pages légales `/legal/[slug]` | 🟡 (contenu à publier) |

## Recette

- Scénario R-P0-09 — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. Valider export contient messages, swipes, matches (pas seulement compteurs)
2. Valider soft delete + anonymisation
3. Publier CGU et privacy via CMS
