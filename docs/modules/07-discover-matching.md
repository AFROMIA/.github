# Module 07 — Discover & matching (SAFIRI Connect)

**Statut** : 🚧 En cours — migration UX Connect  
**Spec** : DISC-01 à DISC-13 · [CHARTE](../CHARTE_FONDATION.md#positionnement-safiri-connect)  
**Recette** : R-P0-04, R-P1-09, R-P1-19 à R-P1-23 · [RECETTE](../RECETTE.md)

---

## Vision

Parcours de **découverte de connexions** (personnes, scores AFFINIORA) — inspiré des meilleurs patterns swipe, sans se définir comme application de rencontre. L'amour / la rencontre est un **mode** (`meet`), pas l'identité produit.

**Fondations AEE (Adaptive Experience Engine)** : sélecteur de contexte en tête de `/discover` :

| Mode | ID | Usage |
|------|-----|--------|
| Connexions | `connections` | Feed mixte, copy neutre |
| Rencontre | `meet` | Swipe romantique (ex-Love) |
| Réseau | `network` | Filtre networking, CTA « Connecter » |

## Exigences clés

| ID | Exigence |
|----|----------|
| DISC-10 | Modale filtres cachée par défaut, compacte, déplaçable |
| DISC-11 | Hub flottant : filtres + Sarielle + shop |
| DISC-12 | Célébration connexion + confettis + score Affiniora |
| DISC-13 | **Modes contexte Connect** — sélecteur, filtres presets, copy/i18n par mode |

## État réel

| Composant | État |
|-----------|------|
| Feed, swipes, matches (API) | ✅ |
| Filtres PostGIS | ✅ (4 tests pytest) |
| `DiscoverFloatingHub` | ✅ |
| `ConnectModeSelector` + `useDiscoverContext` | ✅ (S5b) |
| `SwipeCardStack` adaptatif par mode | ✅ (S5b) |
| `MatchCelebration` i18n Connect | ✅ (S5b) |
| Gate email vérifié | ✅ |

## Fichiers clés

- `discover/page.tsx`, `ConnectModeSelector.tsx`, `useDiscoverContext.ts`
- `SwipeCardStack.tsx`, `MatchCelebration.tsx`
- `discovery.py`, `swipes.py`, `matches.py`
- i18n : `connect.*`, `discover.*`

## Actions

1. Recette modes Connect (R-P1-19 à R-P1-23)
2. E2E `discover-modes.spec.ts`
3. Étendre presets réseau (`friendship`) si besoin
