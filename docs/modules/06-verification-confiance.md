# Module 06 — Vérification & confiance

**Statut** : 🟡 Partiel  
**Spec** : TRUST-01 à TRUST-08

---

## Vision

Selfie vidéo 10–30 s, traitement async, modération admin, gate Discover, blocage/signalement.

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Upload vidéo S3 | ✅ | `/verify-video` |
| Traitement Celery | ❌ | Worker absent en dev local |
| Liveness ML | 🔴 | Anti-fake texte seulement (MVP) |
| Admin approve/reject | ✅ | Panel admin |
| Gate Discover | 🟡 | `DISCOVER_REQUIRE_VERIFICATION=false` par défaut |

## Actions

1. Lancer Celery pour traitement async
2. Recette R-P0-07
3. Phase 2 : vrai liveness vidéo
