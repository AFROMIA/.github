# Module 21 — Badges & intentions i18n

**Statut** : 🟡 Partiel  
**Dépôt** : [SAFIRI](https://github.com/AFROMIA/SAFIRI)

---

## Vision

**Badges** : récompenses visibles sur profil (confiance, activité, premium).  
**Intentions** : catalogue relationnel multilingue (10 locales) avec sondes interactives pour affiner le matching.

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Migrations 015, 017, 018 | ✅ | badges, intention_probes, i18n |
| `badge_service`, catalogue domaine | ✅ | Attribution + sync |
| `intention_probe_service` | ✅ | Génération sondes |
| Admin panels badges/intentions | ✅ | CMS interne |
| UI `BadgePicker`, `IntentionProbeModal` | ✅ | Discover + profil |
| Revue linguistique | 🟡 | Traductions auto non validées |

## Solution proposée

1. Définir règles d'attribution badges (doc métier)
2. Revue native speaker FR/EN/AR des intentions
3. CI : `scripts/merge-i18n-extensions.mjs` sur PR i18n
4. Tests pagination `useIntentionPagination`

## Compétences requises

- **i18n** : next-intl, gestion catalogues JSON multilingues
- **Backend** : règles métier, seeds `badge_seed`, `intention_probe_seed`
- **UX** : micro-interactions sondes, accessibilité modales
- **Produit** : taxonomie intentions relationnelles culturellement pertinente

## Fichiers clés (SAFIRI)

- `apps/backend/app/domain/intention_catalog.py`
- `apps/frontend/src/components/intention/`
- `packages/shared-types/src/badges.ts`
