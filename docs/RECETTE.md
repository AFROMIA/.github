# AFROMIA / SAFIRI — Plan de recette & couverture tests

**Version** : 2.0  
**Date** : 22 juin 2026  

**Documents liés** : [État d'avancement](./ETAT_AVANCEMENT.md) · [Spécification](./SPECIFICATION_FONCTIONNELLE.md) · [Comptes test](./COMPTES_TEST.md) · [Modules](./modules/README.md)

---

## Table des matières

1. [Stratégie de test](#1-stratégie-de-test)
2. [Inventaire des tests automatisés](#2-inventaire-des-tests-automatisés)
3. [Couverture par module](#3-couverture-par-module)
4. [Scénarios de recette manuelle](#4-scénarios-de-recette-manuelle)
5. [Prérequis environnement recette](#5-prérequis-environnement-recette)
6. [Matrice traçabilité spec ↔ tests](#6-matrice-traçabilité-spec--tests)
7. [Backlog tests à créer](#7-backlog-tests-à-créer)

---

## 1. Stratégie de test

### Pyramide MVP

```
        ┌─────────────────┐
        │ Recette manuelle │  Sarielle (PO) — chaque module
        │ (checklist)      │  avant sign-off staging
        ├─────────────────┤
        │ E2E Playwright   │  Parcours critiques (objectif S7)
        │ (3 → 15+ specs)  │
        ├─────────────────┤
        │ Tests API/intég. │  pytest avec DB de test
        │ (quasi absent)   │
        ├─────────────────┤
        │ Tests unitaires  │  auth, RBAC, discovery, AFFINIORA
        └─────────────────┘
```

### Rôles

| Rôle | Responsabilité |
|------|----------------|
| **Sarielle (PO)** | Recette fonctionnelle, sign-off par module |
| **Lead Dev** | Tests auto, corrections bugs P0/P1 |

---

## 2. Inventaire des tests automatisés

### Backend SAFIRI (`SAFIRI/apps/backend/tests/`)

| Fichier | Tests | Périmètre |
|---------|-------|-----------|
| `test_auth.py` | 11 | Hash, JWT, register, login, verify, logout |
| `test_auth_routes.py` | 2 | Forgot password, refresh |
| `test_discovery.py` | 4 | Filtres langue, distance, géoloc |
| `test_health.py` | 1 | `/health` |
| `test_oauth_sessions.py` | 5 | OAuth state, suspend, lifecycle |
| `test_rbac.py` | 14 | Hiérarchie rôles, assignation |
| `test_schema.py` | 4 | Tables, extensions, indexes, seed ref |
| **Total** | **~41** | Majoritairement **unitaires/mockés** |

**Commande** :
```powershell
cd SAFIRI\apps\backend
python -m pytest tests/ -v
```

### AFFINIORA (`AFFINIORA/services/ai-engine/tests/`)

| Fichier | Tests | Périmètre |
|---------|-------|-----------|
| `test_scoring.py` | 2 | Health, compatibilité |
| `test_personality.py` | 6 | Quiz, fusion, Sarielle intent |
| `test_sarielle.py` | 2 | Endpoint, frameworks |
| `test_sarielle_llm_async.py` | 6 | Jobs async, historique, feedback |
| `test_integration.py` | 2 | Précision, frameworks |
| **Total** | **18** | |

**Commande** :
```powershell
cd AFFINIORA\services\ai-engine
python -m pytest tests/ -v
```

### E2E Playwright (`SAFIRI/e2e/`)

| Fichier | Scénarios | Périmètre |
|---------|-----------|-----------|
| `mvp.spec.ts` | 3 | Home charge, login visible, blog < 500 |
| `smoke.spec.ts` | (si présent) | Smoke basique |

**Commande** :
```powershell
cd SAFIRI
npx playwright test
```

### Frontend unitaires

| Fichier | Tests | Périmètre |
|---------|-------|-----------|
| Vitest (design tokens) | ~1 | Couleurs — trivial |

### Synthèse couverture

| Couche | Fichiers | Tests | Couverture fonctionnelle estimée |
|--------|----------|-------|----------------------------------|
| Backend unitaire | 7 | ~41 | Auth, RBAC, discovery filtres — **~15 %** du spec |
| AFFINIORA | 5 | 18 | Scoring, personnalité, Sarielle — **~40 %** du moteur IA |
| E2E | 1–2 | 3 | **< 5 %** des parcours utilisateur |
| Recette manuelle | — | 0 validé | Checklist ci-dessous — **à exécuter** |

---

## 3. Couverture par module

| Module | Tests auto | Recette manuelle | Gap principal |
|--------|------------|------------------|---------------|
| Homepage CMS | ❌ | ⬜ | E2E édition CMS + affichage |
| Auth & wizard | ✅ partiel | ⬜ | E2E wizard complet |
| Sarielle | ✅ AFFINIORA | ⬜ | E2E conversation |
| Profils | ❌ | ⬜ | Upload S3, quiz |
| AFFINIORA intégration | 🟡 | ⬜ | Test avec service live |
| Vérification | ❌ | ⬜ | Celery + admin approve |
| Discover | ✅ filtres | ⬜ | E2E swipe → match |
| Chat | ❌ | ⬜ | WS message instantané |
| Premium | ❌ | ⬜ | Stripe test mode |
| Live | ❌ | ⬜ | LiveKit session |
| Shop | ❌ | ⬜ | Achat + envoi cadeau |
| WebRTC | ❌ | ⬜ | Appel 2 navigateurs |
| CMS/Blog | ❌ | ⬜ | Article détail |
| Notifications | ❌ | ⬜ | Push subscribe |
| Admin | 🟡 RBAC | ⬜ | Modération workflow |
| RGPD | ❌ | ⬜ | Export + delete |
| Design/UX | ❌ | ⬜ | Thèmes, responsive |

Légende : ✅ = tests existants · ⬜ = non exécuté · ❌ = aucun test

---

## 4. Scénarios de recette manuelle

### 4.1 Parcours cœur (P0 — bloquant lancement)

| ID | Scénario | Étapes | Résultat attendu | Statut |
|----|----------|--------|------------------|--------|
| R-P0-01 | Inscription wizard | Getting Started → email → profil → quiz → consentement IA | Wizard terminé sans redirect prématuré | ⬜ |
| R-P0-02 | Vérification email | Inscription → email dev loggé → clic lien | Accès Discover débloqué | ⬜ |
| R-P0-03 | Quiz → personnalité | 12 questions → attente Celery | `/personality` affiche traits IA | ⬜ |
| R-P0-04 | Discover | Filtres, scores Affiniora réels, swipe | Cartes avec score ≠ 65 fallback | ⬜ |
| R-P0-05 | Match | Like mutuel | Confettis + conversation créée | ⬜ |
| R-P0-06 | Chat temps réel | Envoi message | Message visible immédiatement (pas refresh) | ⬜ |
| R-P0-07 | Vérif vidéo | Enregistrement → admin approve | Statut vérifié, gate Discover OK | ⬜ |
| R-P0-08 | Signalement | Report → admin résout | Workflow complet | ⬜ |
| R-P0-09 | RGPD | Export + suppression compte test | Données exportées, compte soft-deleted | ⬜ |

### 4.2 Homepage & CMS (P1)

| ID | Scénario | Résultat attendu | Statut |
|----|----------|------------------|--------|
| R-P1-01 | Édition hero CMS admin | Texte visible sur `/` sans redémarrage serveur | ⬜ |
| R-P1-02 | Traduction FR/EN homepage | Contenu CMS par locale + fallback | ⬜ |
| R-P1-03 | Galerie upload local | Photo/vidéo uploadée visible homepage | ⬜ |
| R-P1-04 | Newsletter | Soumission → enregistrement backend | ⬜ |
| R-P1-05 | Contact | Soumission → notification admin | ⬜ |
| R-P1-06 | Ancres navigation | Liens ancres **uniquement** sur `/` | ⬜ |

### 4.3 Sarielle & AFFINIORA (P1)

| ID | Scénario | Résultat attendu | Statut |
|----|----------|------------------|--------|
| R-P1-07 | Chat Sarielle | Réponse IA (pas template offline) | ⬜ |
| R-P1-08 | Sarielle navigation | Demande lien → redirection page | ⬜ |
| R-P1-09 | Onglet Affiniora Discover | Question compatibilité → réponse | ⬜ |
| R-P1-10 | Consentement IA | Case décochée par défaut ; cocher active accompagnement | ⬜ |

### 4.4 Premium & monétisation (P1)

| ID | Scénario | Résultat attendu | Statut |
|----|----------|------------------|--------|
| R-P1-11 | Checkout Stripe staging | Abonnement actif, rôle premium | ⬜ |
| R-P1-12 | Likes reçus premium | Liste visible abonné | ⬜ |
| R-P1-13 | Achat cadeau virtuel | Cadeau dans chat match | ⬜ |

### 4.5 Admin & notifications (P2)

| ID | Scénario | Résultat attendu | Statut |
|----|----------|------------------|--------|
| R-P2-01 | KPI dashboard | Métriques cohérentes | ⬜ |
| R-P2-02 | Utilisateurs en ligne | Liste sans erreur CORS/500 | ⬜ |
| R-P2-03 | Notification interne | Nouvelle inscription visible admin | ⬜ |
| R-P2-04 | Message admin → user | User reçoit message | ⬜ |

### 4.6 Social avancé (P2)

| ID | Scénario | Résultat attendu | Statut |
|----|----------|------------------|--------|
| R-P2-05 | Live session | Stream + commentaires WS | ⬜ |
| R-P2-06 | Appel vidéo | 2 navigateurs, audio/vidéo | ⬜ |
| R-P2-07 | Profil public / privacy | matches_only masque profil | ⬜ |
| R-P2-08 | Push PWA | Notification match reçue | ⬜ |

---

## 5. Prérequis environnement recette

```powershell
# 1. Stack complète
cd "C:\Users\MAITRE\Documents\IronCorp technologies\AFROMIA"
make bootstrap
make dev

# 2. Celery (terminal séparé — OBLIGATOIRE pour IA async)
cd SAFIRI\apps\backend
$env:ENV_FILE = "..\..\.env"
python -m celery -A app.workers.celery_app worker --loglevel=info

# 3. Vérifier services
curl http://localhost:8000/health
curl http://localhost:8001/health   # AFFINIORA
```

**Comptes** : voir [COMPTES_TEST.md](./COMPTES_TEST.md).

---

## 6. Matrice traçabilité spec ↔ tests

| ID Spec | Fonctionnalité | Test auto | Recette |
|---------|----------------|-----------|---------|
| AUTH-01 | Inscription | `test_auth_service_register` | R-P0-01 |
| AUTH-04 | Vérif email | `test_purpose_token_email_verify` | R-P0-02 |
| AI-01 | Score compatibilité | `test_compatibility_score` (AFFINIORA) | R-P0-04 |
| DISC-04 | Swipe | — | R-P0-05 |
| CHAT-03 | WebSocket | — | R-P0-06 |
| TRUST-01 | Vérif vidéo | — | R-P0-07 |
| PREM-01 | Stripe | — | R-P1-11 |
| GDPR-01 | Export | — | R-P0-09 |
| CMS-HP-01 | Homepage CMS | — | R-P1-01 |
| SAR-01 | Agent Sarielle | `test_sarielle_endpoint` | R-P1-07 |

*Liste complète des IDs : [SPECIFICATION_FONCTIONNELLE.md](./SPECIFICATION_FONCTIONNELLE.md)*

---

## 7. Backlog tests à créer

### Priorité P0 (avant staging)

- [ ] E2E : inscription wizard → personality → discover
- [ ] E2E : swipe → match → chat (message visible)
- [ ] pytest : intégration chat WebSocket
- [ ] pytest : swipe + match creation
- [ ] E2E : admin modération signalement

### Priorité P1

- [ ] E2E : CMS homepage edit → revalidate → visible
- [ ] E2E : Sarielle conversation (mock AFFINIORA)
- [ ] pytest : premium webhook Stripe (mock)
- [ ] E2E : RGPD export/delete

### Priorité P2

- [ ] E2E : live session (skip si pas LiveKit)
- [ ] E2E : WebRTC call (2 contexts Playwright)
- [ ] pytest : push subscribe endpoint
- [ ] Couverture pytest > 50 % backend services

---

*Mettre à jour les colonnes Statut après chaque session de recette. Objectif S7 : 100 % scénarios P0 verts.*
