# Module 07 — Discover & matching

**Statut** : 🟡 Partiel  
**Spec** : DISC-01 à DISC-12

---

## Vision

Feed type Tinder avec scores Affiniora, filtres avancés en modale déplaçable (onglets : filtres / Affiniora / boutique), confettis au match.

## Exigences clés (ajouts utilisateur)

| ID | Exigence |
|----|----------|
| DISC-10 | Modale filtres cachée par défaut, compacte, déplaçable |
| DISC-11 | Hub flottant : filtres + Affiniora + shop |
| DISC-12 | Animation match avec confettis + score réel |

## État réel

| Composant | État |
|-----------|------|
| Feed, swipes, matches | ✅ |
| Filtres PostGIS | ✅ (4 tests pytest) |
| `DiscoverFloatingHub` | ✅ |
| `MatchCelebration` | 🟡 (confettis — à valider) |
| Gate email vérifié | ✅ |

## Fichiers clés

- `discovery.py`, `swipes.py`, `matches.py`
- `discover/page.tsx`, `SwipeCardStack`, `DiscoverFilterPanel`

## Actions

1. Recette swipe → match (R-P0-05)
2. Valider modale déplaçable UX
3. E2E discover avec comptes seed
