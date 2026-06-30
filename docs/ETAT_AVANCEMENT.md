# AFROMIA / SAFIRI — État d'avancement réel

**Version** : 2.3  
**Date** : 29 juin 2026  
**Statut** : Document de vérité technique — à mettre à jour à chaque sprint  

**Documents liés** : [VISION](./VISION.md) · [Spécification](./SPECIFICATION_FONCTIONNELLE.md) · [Recette](./RECETTE.md) · [Modules](./modules/README.md)

**Dépôts** : [SAFIRI](https://github.com/AFROMIA/SAFIRI) · [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) · [Docs `.github`](https://github.com/AFROMIA/.github) · [Contrat IA v2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md)

---

## Table des matières

1. [Synthèse exécutive](#1-synthèse-exécutive)
2. [Légende des statuts](#2-légende-des-statuts)
3. [Matrice globale](#3-matrice-globale)
4. [Fonctionnalités récentes — état, solutions, compétences](#4-fonctionnalités-récentes--état-solutions-compétences)
5. [Bloqueurs transverses](#5-bloqueurs-transverses)
6. [Détail par module historique](#6-détail-par-module-historique)
7. [Infrastructure & dépendances](#7-infrastructure--dépendances)
8. [Prochaines priorités recommandées](#8-prochaines-priorités-recommandées)

---

## 1. Synthèse exécutive

> **Constat honnête (juin 2026)** : code **vaste** (35+ routes, 30+ modules API, 10 migrations récentes, Terraform 79 ressources). Sprint juin : channels, wallet, badges, intentions, speed dating, contrat IA v2, **pipeline déploiement AWS**. La doc et les scripts sont sur Git ([`.github`](https://github.com/AFROMIA/.github)) — un nouveau dev clone 3 dépôts et suit [README.md](./README.md). Recette bout-en-bout et staging AWS **non validés**.

| Indicateur | Valeur estimée | Commentaire |
|------------|----------------|-------------|
| Code backend | ~90 % écrit | Channels, wallet, IA v2 |
| Code frontend | ~85 % écrit | Nouvelles pages livrées |
| Intégration AFFINIORA v2 | ~60 % | Docker + Celery + clés cloud |
| **Infra AWS staging** | ~70 % préparé | Terraform plan OK ; apply bloqué IAM |
| Services tiers | ~15 % | Stripe/Campay codés, clés absentes |
| Tests automatisés | ~25 % | +profile IA, résilience DB/Redis |
| Recette manuelle | ~25 % | Staging non sign-off |
| **Documentation Git** | ~95 % | Modules 01–22, infra, scripts en ligne |

**Ce qui marche le mieux** : design system, navigation, admin shell, debug panel IA Lab, fixtures enrichies, orchestration `make dev-split`.

**Ce qui bloque le plus** : secrets tiers vides, Celery non lancé par défaut, recette channels/paiements absente, push notifications inactives.

---

## 2. Légende des statuts

| Statut | Signification |
|--------|---------------|
| ✅ **Opérationnel** | Fonctionne en local avec stack standard + seed |
| 🟡 **Partiel** | Code présent ; dépend config externe, service manquant ou UX incomplète |
| 🚧 **En cours** | Développement ou recette active ; bugs connus |
| 🔴 **Non opérationnel** | Config manquante ou parcours non testable |
| ❌ **Cassé** | Code présent mais dysfonctionnel en l'état |

---

## 3. Matrice globale

| Module | Backend | Frontend | BtB local | Statut | Fiche |
|--------|---------|----------|-----------|--------|-------|
| Homepage & CMS | ✅ | ✅ | 🟡 | 🟡 | [01](./modules/01-homepage-cms.md) |
| Auth & wizard | ✅ | ✅ | 🟡 | 🟡 | [02](./modules/02-auth-wizard.md) |
| Sarielle | ✅ | ✅ | 🟡 | 🟡 | [03](./modules/03-sarielle.md) |
| Profils & onboarding | ✅ | ✅ | 🟡 | 🟡 | [04](./modules/04-profils-onboarding.md) |
| AFFINIORA (IA v2) | ✅ | ✅ | 🟡 | 🟡 | [05](./modules/05-affiniora.md) |
| Vérification & confiance | ✅ | ✅ | ❌ | 🟡 | [06](./modules/06-verification-confiance.md) |
| Discover & matching | ✅ | ✅ | 🟡 | 🟡 | [07](./modules/07-discover-matching.md) |
| Chat & messagerie | ✅ | ✅ | 🟡 | 🚧 | [08](./modules/08-chat-messagerie.md) |
| Premium & paiements | ✅ | 🟡 | 🟡 | 🟡 | [09](./modules/09-premium-paiements.md) |
| Live streaming | ✅ | ✅ | 🟡 | 🟡 | [10](./modules/10-live-streaming.md) |
| Boutique cadeaux | ✅ | ✅ | 🟡 | 🟡 | [11](./modules/11-boutique-cadeaux.md) |
| Appels WebRTC | ✅ | ✅ | 🟡 | 🟡 | [12](./modules/12-webrtc-appels.md) |
| CMS & blog | ✅ | 🟡 | 🟡 | 🟡 | [13](./modules/13-cms-blog.md) |
| Notifications | ✅ | ✅ | ❌ | 🔴 | [14](./modules/14-notifications.md) |
| Admin & modération | ✅ | ✅ | 🟡 | 🟡 | [15](./modules/15-admin-moderation.md) |
| RGPD | ✅ | ✅ | 🟡 | 🟡 | [16](./modules/16-rgpd.md) |
| Design & UX | — | ✅ | ✅ | ✅ | [17](./modules/17-design-ui-ux.md) |
| Infra & DevOps | ✅ | — | 🟡 | 🚧 | [18](./modules/18-infra-devops.md) |
| **Channels créateur** | ✅ | ✅ | 🟡 | 🟡 | [19](./modules/19-channels-createur.md) |
| **Wallet Safir** | ✅ | ✅ | 🟡 | 🟡 | [20](./modules/20-wallet-safir.md) |
| **Badges & intentions** | ✅ | ✅ | 🟡 | 🟡 | [21](./modules/21-badges-intentions.md) |
| **Speed dating** | ✅ | ✅ | 🟡 | 🚧 | [22](./modules/22-speed-dating.md) |

*BtB = bout-en-bout testable en local avec seed*

---

## 4. Fonctionnalités récentes — état, solutions, compétences

Tableau de pilotage pour recrutement, priorisation sprint et mitigation.

| Fonctionnalité | État réel | Solution proposée | Compétences requises |
|----------------|-----------|-------------------|----------------------|
| **Contrat IA v2 (UserProfileIA)** | Schémas SAFIRI + AFFINIORA alignés ; endpoints `profile-full`, coaching, Sarielle jobs codés. Recette partielle. | 1) Documenter flux dans [CONTRACT_V2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md) 2) Test E2E `POST /profiles/me/analyze` 3) Vérifier persistance `analysis_report` | Python FastAPI, Pydantic, TypeScript shared-types, compréhension RAG |
| **Analyse profil + coaching premium** | Moteur `profile_analysis_engine`, gating `ia_gating.py`, wizard profil frontend. Premium cloud LLM inactif sans clés. | 1) Clés OpenAI/Anthropic staging 2) Recette free vs premium 3) Fallback UX « IA indisponible » | ML/NLP (HuggingFace), FastAPI, Next.js, pgvector |
| **Sarielle v2 + routeur LLM** | Routeur cloud/local opérationnel côté AFFINIORA ; debug panel IaLab appelle directement le service. | 1) `make dev-split` systématique 2) Tests charge Sarielle 3) Monitoring latence cloud vs local | LLM ops, FastAPI, CORS, Celery |
| **Channels créateur** | API complète (CRUD, abonnements, engagement, inquiries) ; UI `/channels`, studio créateur, admin monitor. Non recetté bout-en-bout. | 1) Seed `channel_seed` + parcours créateur 2) Tests Playwright checkout offering 3) Modération contenu | FastAPI, SQLAlchemy, Next.js App Router, Stripe (offerings) |
| **Wallet Safir** | Monnaie interne, API wallet/currency, UI `/wallet`, client Campay codé. Aucune clé Campay configurée. | 1) Compte Campay sandbox 2) Recette crédit/débit/tip 3) Réconciliation ledger DB | Paiements mobile money (Afrique), FastAPI transactions, idempotence webhooks |
| **Premium checkout** | Pages `/premium/checkout`, webhooks Stripe codés. Clés Stripe vides ; `/premium/success` partiel. | 1) Stripe test mode 2) E2E checkout → rôle premium 3) Page confirmation | Stripe API, webhooks sécurisés, Next.js |
| **Badges** | Catalogue domaine, sync service, admin panel, composants UI. Attribution auto peu testée. | 1) Règles métier documentées 2) Tests `badge_service` 3) Affichage profil public | Domain-driven design, règles métier, React |
| **Intentions i18n** | Catalogue + sondes + 10 locales ; `IntentionProbeModal`. Traductions partiellement validées par locuteurs natifs. | 1) Revue linguistique FR/EN/AR 2) Script `merge-i18n-extensions.mjs` en CI 3) Tests pagination intentions | next-intl, i18n, UX research |
| **Speed dating** | Orchestrateur + WS + LiveKit helpers ; room UI basique. LiveKit local requis, non documenté au onboarding. | 1) Guide LiveKit dans [start.md](../start.md) 2) Test session 2 utilisateurs seed 3) Gestion timeouts | WebSocket, LiveKit, orchestration temps réel |
| **Résilience DB/Redis** | Couche `resilience.py` + client Redis dédié ; tests unitaires. Pas de chaos testing. | 1) Simuler panne Redis en dev 2) Circuit breaker dashboard 3) Alertes Prometheus | SRE, PostgreSQL, Redis, pytest |
| **Déploiement AWS staging** | Terraform + scripts livrés ; ECR/ECS prêts ; IAM `afromia-dev-agent` sans droits create | 1) [IAM_BLOCKER](./infra/IAM_BLOCKER.md) 2) `bootstrap-aws.ps1` 3) smoke health checks | AWS IAM, Terraform, ECS, Docker |
| **Debug panel IA Lab** | Appels directs navigateur → AFFINIORA. Fonctionnel si service up. | 1) Variables `NEXT_PUBLIC_AFFINIORA_*` 2) Masquer en prod | Next.js, CORS, sécurité clés |

### Onboarding équipe distribuée

| Besoin | Ressource Git |
|--------|---------------|
| Choisir un chantier | [modules/](./modules/README.md) + tableau ci-dessus |
| Setup local | [README.md](./README.md) — clone 3 dépôts |
| Déployer | [infra/README.md](./infra/README.md) |
| Tester | [RECETTE.md](./RECETTE.md) |

**Prérequis org** : accès GitHub AFROMIA (SAFIRI, AFFINIORA, `.github`). Configurer [branch protection](./infra/GITHUB_BRANCH_PROTECTION.md) pour travail en équipe. AWS optionnel.

## 5. Bloqueurs transverses

| # | Bloqueur | Impact | Modules | Mitigation |
|---|----------|--------|---------|------------|
| B1 | **AFFINIORA + Celery non auto-lancés** | IA, Sarielle, analyse async HS | 03, 05, 19 | `make dev-split` documenté ; [start.md](../start.md) |
| B2 | **Secrets tiers vides** | Paiements, OAuth, push, Campay | 09, 14, 20 | Sprint config ; templates [env-profiles](./env-profiles/) |
| B3 | **SMTP vide** | Gate email Discover bloqué | 02, 07 | `email_dev_mode` ou comptes seed staff |
| B4 | **Recette nouvelles features absente** | Channels, wallet, speed dating non validés | 19–22 | Scénarios dans [RECETTE.md](./RECETTE.md) à étendre |
| B5 | **Tests E2E insuffisants** | Régressions non détectées | Tous | Playwright parcours MVP + channels |
| B6 | **CMS sans seed** | Homepage fallback i18n seul | 01, 13 | Publier contenu admin |
| B7 | **Chat optimiste fragile** | Refresh nécessaire parfois | 08 | Fix P0 WebSocket ack |
| B8 | **IAM AWS insuffisant** | Terraform apply impossible | 18 | [IAM_BLOCKER](./infra/IAM_BLOCKER.md) |
| B9 | **Staging non recetté** | Pas d'URL publique validée | Tous | Deploy + smoke après IAM |

---

## 6. Détail par module historique

Résumé des modules 01–18. Voir fiches détaillées dans [modules/](./modules/).

### Premium & paiements (🟡 — amélioration juin 2026)
- Checkout Stripe + Campay **codés** ; clés API **absentes**.
- Page `/premium/checkout` ajoutée ; webhooks à valider en staging.

### AFFINIORA (🟡 — contrat v2)
- Fallback score 65 encore possible si service down.
- Debug panel permet de tester sans passer par SAFIRI backend.

### Chat (🚧)
- WebSocket + typing + suggestions IA.
- Bugs signalés : visibilité message immédiate.

### Notifications (🔴)
- VAPID vide ; push non fonctionnel.

---

## 7. Infrastructure & dépendances

### Stack minimale (parcours complet)

```
make bootstrap → make dev-split
  ├── Docker : Postgres, Redis, MinIO (SAFIRI)
  ├── Docker : AFFINIORA ai-engine :8001
  ├── Migrations (012–021) + seed
  ├── Backend :8000 + Frontend :3000
  ├── Terminal Affiniora (si pas compose unifié)
  └── Celery worker (recommandé)
```

### Scripts & docs

| Ressource | Lien |
|-----------|------|
| Démarrage rapide | [start.md](../start.md) |
| Guide développeur | [docs/README.md](./README.md) |
| Scripts orchestration | [docs/scripts/](./scripts/) |
| **Déploiement AWS** | [infra/README.md](./infra/README.md) · [AWS_DEPLOYMENT](./infra/AWS_DEPLOYMENT.md) |
| Comptes test | [COMPTES_TEST.md](./COMPTES_TEST.md) |

---

## 8. Prochaines priorités recommandées

1. **Déploiement AWS staging** — débloquer IAM, `bootstrap-aws.ps1`, deploy ECR/ECS, smoke
2. **Config staging** — Stripe test + Campay sandbox + clés AFFINIORA cloud
3. **Recette channels** — parcours créateur → offering → checkout
4. **Recette wallet** — crédit Safir, tip, conversion devise
5. **AFFINIORA fiable** — `make dev-split` par défaut ; scores réels Discover
6. **Chat P0** — fix message optimiste
7. **E2E Playwright** — étendre au-delà du smoke MVP
8. **Accès GitHub** — inviter contributeurs sur les 3 dépôts

---

*Document maintenu par l'équipe AFROMIA. Dépôt informationnel : [github.com/AFROMIA/.github](https://github.com/AFROMIA/.github).*
