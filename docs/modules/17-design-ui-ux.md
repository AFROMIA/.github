# Module 17 — UI/UX & design system

**Statut** : ✅ Opérationnel (meilleur état du projet)  
**Spec** : UX-01 à UX-10

---

## Vision

Expérience premium chaleureuse : thèmes clair/sombre, design épuré, responsive, **logos AFROMIA + SAFIRI** en navigation (`BrandLockup`), barres compactes, loaders romantiques, confettis match, micro-copy plaisante.

**Assets** : `SAFIRI/apps/frontend/public/brand/logo.jpeg` (SAFIRI) · `afromia_logo.png` (AFROMIA) · [Charte](../CHARTE_FONDATION.md#identité-visuelle)

## État réel

| Composant | État |
|-----------|------|
| Thèmes clair / sombre / système | ✅ |
| Lisibilité dark mode | ✅ |
| Design épuré + responsive | ✅ |
| Logo dual AFROMIA + SAFIRI (nav) | ✅ |
| Logo +30 %, ombre portée | ✅ |
| Barres navigation compactes | ✅ |
| Loaders proverbes africains | ✅ |
| Confettis match | 🟡 (à valider en recette) |
| Transitions / feedback actions | 🟡 |

**Référence** : [docs/ux/design.md](../ux/design.md)

## Recette

- Validation visuelle Promoteur — voir [RECETTE.md](../RECETTE.md)
- 1 test Vitest tokens (trivial)

## Actions prioritaires

1. Valider confettis au match (R-P0-05)
2. Audit contraste WCAG AA dark mode sur pages récentes
3. Loader visible < 200 ms sur actions lentes
