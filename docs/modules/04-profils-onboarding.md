# Module 04 — Profils & onboarding

**Statut** : 🟡 Partiel  
**Spec** : PROF-01 à PROF-12 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-2--profil--onboarding)

---

## Vision

Profil riche (bio, médias, intérêts, géoloc PostGIS), complétion %, posts sociaux, confidentialité (public / matches_only), pages visitables depuis Discover/Matches/Chat.

## Exigences clés (ajouts utilisateur)

| ID | Exigence |
|----|----------|
| PROF-10 | Réglage visibilité : matches_only vs public |
| PROF-11 | Pages profil visitables depuis Discover/Matches/Chat |
| PROF-12 | `/personality` : voir toutes sections même déjà remplies |
| PROF-13 | Photos/vidéos optionnelles wizard avec impact accès services |

## État réel

| Composant | État |
|-----------|------|
| CRUD profil, photos S3 | ✅ |
| Quiz, analyse personnalité | 🟡 (Celery + AFFINIORA) |
| `/profile/studio`, `/creator` | ✅ |
| Privacy settings | ✅ |
| Upload médias | 🟡 (MinIO requis) |

## Fichiers clés

- `SAFIRI/apps/backend/app/api/v1/profiles.py`
- `SAFIRI/apps/frontend/src/app/profile/`, `/personality/`, `/onboarding/`

## Tests : ❌ auto · Recette ⬜

## Actions

1. Valider upload photos MinIO bout-en-bout
2. Page personality : navigation toutes sections
3. pytest CRUD profil + completion
