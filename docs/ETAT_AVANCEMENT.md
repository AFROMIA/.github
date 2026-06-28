# AFROMIA / SAFIRI — État d'avancement réel

**Version** : 2.1  
**Date** : 28 juin 2026  
**Statut** : Document de vérité technique — à mettre à jour à chaque sprint  

**Documents liés** : [VISION](./VISION.md) · [Spécification](./SPECIFICATION_FONCTIONNELLE.md) · [Recette](./RECETTE.md) · [Modules](./modules/README.md)

---

## Table des matières

1. [Synthèse exécutive](#1-synthèse-exécutive)
2. [Légende des statuts](#2-légende-des-statuts)
3. [Matrice globale](#3-matrice-globale)
4. [Bloqueurs transverses](#4-bloqueurs-transverses)
5. [Détail par module](#5-détail-par-module)
6. [Infrastructure & dépendances](#6-infrastructure--dépendances)
7. [Prochaines priorités recommandées](#7-prochaines-priorités-recommandées)

---

## 1. Synthèse exécutive

> **Constat honnête (juin 2026)** : le dépôt contient une base de code **vaste et structurée** (~30 routes frontend, ~20 modules API backend, microservice AFFINIORA séparé). En revanche, **peu de parcours sont opérationnels de bout en bout sans configuration manuelle** de l'infrastructure et des secrets. L'impression « rien ne fonctionne » est compréhensible si l'on attend un produit prêt à l'emploi après `make dev` seul.

| Indicateur | Valeur estimée | Commentaire |
|------------|----------------|-------------|
| Code backend (modules API) | ~85 % écrit | Peu testé en intégration |
| Code frontend (pages/composants) | ~80 % écrit | Plusieurs routes manquantes ou cassées |
| Intégration AFFINIORA | ~50 % opérationnelle | Dépend service Docker séparé + Celery |
| Services tiers configurés | ~10 % | Stripe, SMTP, OAuth, VAPID vides |
| Tests automatisés | ~25 % couverture utile | 37+ tests backend + nouveaux tests AFFINIORA profile IA + 3 E2E smoke |
| Recette manuelle validée | ~20 % | Aucun sign-off staging |

**Ce qui marche le mieux** : design system, navigation, landing i18n (fallback), admin shell (compte staff seed).

**Ce qui bloque le plus** : vérification email sans SMTP, AFFINIORA/Celery absents du dev local standard, paiements non configurés, CMS sans contenu seedé, blog détail manquant.

---

## 2. Légende des statuts

| Statut | Signification |
|--------|---------------|
| ✅ **Opérationnel** | Fonctionne en local avec la stack standard (`make dev`) et données seed |
| 🟡 **Partiel** | Code présent mais dépend config externe, service manquant ou UX incomplète |
| 🚧 **En cours** | Développement ou recette active ; bugs connus non résolus |
| 🔴 **Non implémenté** | Absent ou placeholder uniquement |
| ❌ **Cassé** | Code présent mais ne fonctionne pas en l'état |

---

## 3. Matrice globale

| Module | Backend | Frontend | BtB local | Statut | Fiche |
|--------|---------|----------|-----------|--------|-------|
| Homepage & CMS | ✅ | ✅ | 🟡 | 🟡 | [modules/01-homepage-cms.md](./modules/01-homepage-cms.md) |
| Auth & wizard | ✅ | ✅ | 🟡 | 🟡 | [modules/02-auth-wizard.md](./modules/02-auth-wizard.md) |
| Sarielle (agent) | ✅ | ✅ | 🟡 | 🟡 | [modules/03-sarielle.md](./modules/03-sarielle.md) |
| Profils & onboarding | ✅ | ✅ | 🟡 | 🟡 | [modules/04-profils-onboarding.md](./modules/04-profils-onboarding.md) |
| AFFINIORA (IA) | ✅ | ✅ | 🟡 | 🟡 | [modules/05-affiniora.md](./modules/05-affiniora.md) |
| Vérification & confiance | ✅ | ✅ | ❌ | 🟡 | [modules/06-verification-confiance.md](./modules/06-verification-confiance.md) |
| Discover & matching | ✅ | ✅ | 🟡 | 🟡 | [modules/07-discover-matching.md](./modules/07-discover-matching.md) |
| Chat & messagerie | ✅ | ✅ | 🟡 | 🚧 | [modules/08-chat-messagerie.md](./modules/08-chat-messagerie.md) |
| Premium & paiements | ✅ | 🟡 | 🟡 | 🟡 | [modules/09-premium-paiements.md](./modules/09-premium-paiements.md) |
| Live streaming | ✅ | ✅ | 🟡 | 🟡 | [modules/10-live-streaming.md](./modules/10-live-streaming.md) |
| Boutique cadeaux | ✅ | ✅ | 🟡 | 🟡 | [modules/11-boutique-cadeaux.md](./modules/11-boutique-cadeaux.md) |
| Appels WebRTC | ✅ | ✅ | 🟡 | 🟡 | [modules/12-webrtc-appels.md](./modules/12-webrtc-appels.md) |
| CMS & blog | ✅ | 🟡 | 🟡 | 🟡 | [modules/13-cms-blog.md](./modules/13-cms-blog.md) |
| Notifications | ✅ | ✅ | ❌ | 🔴 | [modules/14-notifications.md](./modules/14-notifications.md) |
| Admin & modération | ✅ | ✅ | 🟡 | 🟡 | [modules/15-admin-moderation.md](./modules/15-admin-moderation.md) |
| RGPD | ✅ | ✅ | 🟡 | 🟡 | [modules/16-rgpd.md](./modules/16-rgpd.md) |
| Design & UX | — | ✅ | ✅ | ✅ | [modules/17-design-ui-ux.md](./modules/17-design-ui-ux.md) |
| Infra & DevOps | ✅ | — | 🟡 | 🚧 | [modules/18-infra-devops.md](./modules/18-infra-devops.md) |

*BtB = bout-en-bout (parcours utilisateur complet testable)*

---

## 4. Bloqueurs transverses

| # | Bloqueur | Impact | Modules touchés | Mitigation |
|---|----------|--------|-----------------|------------|
| B1 | **AFFINIORA hors compose SAFIRI** | Scores fake (65 %), Sarielle offline, vérif async HS | 03, 05, 06, 07 | Lancer AFFINIORA via `docs/scripts/dev.ps1` ; documenter |
| B2 | **Celery absent en `dev:local`** | Vérif vidéo, push, scoring async, modération async | 05, 06, 14 | Terminal dédié worker Celery (voir README) |
| B3 | **SMTP vide** | Email non vérifié → gate Discover bloqué | 02, 07 | `email_dev_mode` + lien loggé ; ou comptes staff seed |
| B4 | **Secrets tiers vides** | OAuth, Stripe, PayPal, VAPID, Giphy inactifs | 02, 09, 14 | Sprint config S6 |
| B5 | **Deux parcours onboarding** | `/onboarding` vs `/getting-started` — confusion | 02, 04 | Unifier ou documenter clairement |
| B6 | **CMS sans seed** | Homepage = fallback i18n uniquement | 01, 13 | Publier contenu admin ou seed CMS |
| B7 | **Routes frontend manquantes** | `/blog/[slug]`, `/premium/success` | 09, 13 | Créer pages manquantes |
| B8 | **Tests insuffisants** | Régressions non détectées | Tous | Voir [RECETTE.md](./RECETTE.md) |

---

## 5. Détail par module

Chaque module dispose d'une fiche détaillée dans `docs/modules/`. Résumé des constats critiques :

### Homepage & CMS (🟡)
- API CMS homepage + revalidation Next.js implémentées.
- **Problème** : pas de contenu CMS au seed ; modifications admin parfois non visibles sans revalidation (corrigé partiellement).
- **Manque** : formulaires contact/newsletter à valider bout-en-bout.

### Auth & wizard (🟡)
- Register, login, OAuth (code complet), wizard Getting Started, gate email vérifié.
- **Bug signalé** : inscription wizard connecte trop tôt et saute étapes.
- **Demande utilisateur** : bloquer Discover sans email vérifié — partiellement implémenté (`EmailVerificationGate`).

### Sarielle (🟡)
- Page `/sarielle`, hub flottant, proxy AFFINIORA, jobs async.
- **HS si** AFFINIORA down → mode template/offline.

### Chat (🚧)
- WebSocket + REST + typing + suggestions IA.
- **Bugs signalés** : message pas visible immédiatement ; refresh nécessaire.

### Premium (🔴)
- Code Stripe/PayPal présent ; **aucune clé configurée** ; page `/premium/success` absente.

### Notifications (🔴)
- Backend + WS + Celery ; VAPID vide ; push non fonctionnel.

---

## 6. Infrastructure & dépendances

### Stack minimale pour un parcours utilisateur

```
make bootstrap → make dev
  ├── Docker : Postgres, Redis, MinIO (SAFIRI)
  ├── Docker : AFFINIORA ai-engine :8001 (via dev.ps1)
  ├── Migrations + seed
  ├── Backend :8000 + Frontend :3000
  └── [MANUEL] Celery worker (recommandé)
```

### Comptes de test

Voir [COMPTES_TEST.md](./COMPTES_TEST.md). Mot de passe fixtures : `FixturePass123!` (admin : `AdminPassword123!`).

---

## 7. Prochaines priorités recommandées

Ordre suggéré pour rendre le produit **utilisable module par module** :

1. **Infra** — `make dev` fiable + Celery documenté/lancé automatiquement
2. **Auth** — corriger wizard (pas de connexion prématurée) ; SMTP dev ou bypass recette
3. **AFFINIORA** — garantir service up ; supprimer scores factices visibles
4. **Discover → Match → Chat** — parcours cœur stable (bugs chat P0)
5. **Homepage CMS** — seed contenu + formulaires fonctionnels
6. **Premium** — Stripe staging + page success
7. **Recette** — E2E parcours complet (voir RECETTE.md)

---

*Document maintenu par l'équipe AFROMIA. Mettre à jour après chaque session de recette ou sprint.*
