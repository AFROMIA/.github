# AFROMIA — Document de vision produit

**Version** : 2.0  
**Date** : 22 juin 2026  
**Statut** : MVP v1 — stabilisation & recette  
**Cible production** : mi-août 2026  

**Documents liés** : [Spécification fonctionnelle](./SPECIFICATION_FONCTIONNELLE.md) · [État d'avancement](./ETAT_AVANCEMENT.md) · [Recette](./RECETTE.md) · [Modules](./modules/README.md) · [Planning](./PLANNING_MVP.md)

---

## Table des matières

1. [Résumé exécutif](#1-résumé-exécutif)
2. [Mission et vision](#2-mission-et-vision)
3. [Écosystème produit & naming](#3-écosystème-produit--naming)
4. [Proposition de valeur](#4-proposition-de-valeur)
5. [Public cible et personas](#5-public-cible-et-personas)
6. [Positionnement et identité de marque](#6-positionnement-et-identité-de-marque)
7. [Piliers stratégiques](#7-piliers-stratégiques)
8. [Ambition MVP v1](#8-ambition-mvp-v1)
9. [Critères de succès](#9-critères-de-succès)
10. [Feuille de route produit](#10-feuille-de-route-produit)
11. [Équipe et gouvernance](#11-équipe-et-gouvernance)
12. [Principes directeurs](#12-principes-directeurs)
13. [Risques et opportunités](#13-risques-et-opportunités)

---

## 1. Résumé exécutif

**AFROMIA** est la société éditrice d'un écosystème technologique premium centré sur les rencontres, la confiance et l'intelligence émotionnelle, avec une identité **africaine moderne, internationale et futuriste**.

Trois entités nommées distinctement :

| Nom | Rôle |
|-----|------|
| **SAFIRI** | Application de matchmaking (PWA) — le produit utilisateur |
| **AFFINIORA** | Moteur d'IA self-hosted — scoring, personnalité, anti-fake |
| **Sarielle** | Agent conversationnel — navigation, accompagnement, relation client |

Le MVP v1 combine swipe, messagerie temps réel, homepage CMS multilingue, wizard d'inscription, fonctionnalités premium, live, boutique cadeaux et backoffice admin.

> **État réel (juin 2026)** : une base de code **vaste** existe (backend, frontend, AFFINIORA, infra Docker), mais **peu de parcours sont opérationnels de bout en bout** sans configuration manuelle. Voir [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md) pour le détail honnête module par module.

La phase en cours : **stabilisation**, **recette**, **configuration services tiers**, **tests** et **déploiement** visé mi-août 2026.

---

## 2. Mission et vision

### Mission

Connecter des personnes authentiques à travers une plateforme de rencontres premium, intelligente et sécurisée, qui célèbre l'excellence africaine contemporaine et la sophistication émotionnelle.

### Vision (3–5 ans)

Devenir la référence internationale du **matchmaking premium africain augmenté par l'IA**, reconnu pour :

- la **qualité des matchs** (compatibilité réelle via AFFINIORA, pas seulement l'apparence) ;
- la **confiance** (profils vérifiés, modération proactive, transparence IA) ;
- l'**expérience utilisateur** au niveau des meilleures apps lifestyle ;
- un **écosystème IA propriétaire** réutilisable sur d'autres verticales relationnelles.

### Énoncé vision produit

> *« Un écosystème relationnel premium, chaleureux et intelligent, qui connecte le monde à l'Afrique moderne — une **relation enrichissante**. »*

---

## 3. Écosystème produit & naming

```
┌─────────────────────────────────────────────────────────────────┐
│                        AFROMIA (société)                        │
│         Vision · Branding · Gestion de projet · Go-to-market    │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴───────────────────┐
         ▼                                       ▼
┌─────────────────────┐               ┌─────────────────────┐
│       SAFIRI        │    REST API   │     AFFINIORA       │
│  App de rencontre   │◄─────────────►│   Moteur IA         │
│  Next.js + FastAPI  │               │   FastAPI + HF      │
│  + Homepage CMS     │               │   + Agent Sarielle  │
└─────────────────────┘               └─────────────────────┘
         │                                       │
         │  Postgres · Redis · MinIO · Celery    │  PyTorch · Redis cache
         └───────────────────┬───────────────────┘
                             ▼
                    Infrastructure cloud (AWS / Vercel)
```

| Composant | Rôle | Interface |
|-----------|------|-----------|
| **SAFIRI** | App principale (PWA), homepage CMS, wizard, discover, chat, premium | Web mobile-first |
| **AFFINIORA** | Scoring, personnalité, anti-fake, suggestions | API REST |
| **Sarielle** | Agent conversationnel (navigation, accompagnement) | `/sarielle`, hub flottant |
| **docs/** | Documentation, scripts dev, recette | Équipe interne |

**Principe** : dépôts applicatifs indépendants, **REST + WebSocket**, **IA 100 % self-hosted** au MVP.

---

## 4. Proposition de valeur

### Pour l'utilisateur final

| Besoin | Réponse |
|--------|---------|
| Découvrir SAFIRI | Homepage premium CMS, galerie vision, Sarielle guide |
| S'inscrire facilement | Wizard Getting Started auto-save, multilingue |
| Trouver des matchs pertinents | Scores AFFINIORA réels sur Discover |
| Se sentir en sécurité | Vérification vidéo, anti-fake, modération |
| Converser naturellement | Chat temps réel, GIF, suggestions IA |
| Vivre une expérience premium | Abonnement, boost, visiteurs, live, cadeaux |
| Être accompagné | Sarielle — navigation et relation enrichissante |

### Différenciation

1. **Trois marques complémentaires** — SAFIRI (expérience), AFFINIORA (intelligence), Sarielle (humain augmenté).
2. **IA propriétaire transparente** — pas de faux pourcentages ; l'utilisateur sait quand l'IA est active.
3. **Positionnement premium africain** — élégance, chaleur, proverbes, aspiration.
4. **Écosystème étendu** — au-delà du swipe : live, shop, CMS, appels vidéo, agent conversationnel.

---

## 5. Public cible et personas

### Segments prioritaires (MVP)

| Segment | Priorité |
|---------|----------|
| Diaspora & urbains 25–40 ans | ★★★ |
| Early adopters tech / IA | ★★★ |
| Communauté africaine moderne | ★★★ |

### Personas clés

**Amina, 32 ans** — Consultante (Paris / Dakar). Attirée par vérification profil, scores compatibilité, esthétique premium.

**Kwame, 28 ans** — Développeur (Accra). Teste IA, live, premium. Attend transparence et peu de fake profiles.

**Sarielle (interne)** — CEO / Product Owner. Vision, branding, recette, documentation.

**Lead Dev (interne)** — Full Stack. SAFIRI, AFFINIORA, infra, tests.

---

## 6. Positionnement et identité de marque

### Positionnement

**Premium African futuristic lifestyle & AI-powered matchmaking platform.**

### ADN visuel (réf. `docs/ux/design.md`)

- **Modernité** : interfaces légères, compétitives avec les meilleures apps.
- **Chaleur** : palette vibrante ; proverbes africains ; loaders romantiques.
- **Premium** : niveau Apple / Stripe en soin du détail.
- **Lisibilité** : thèmes clair/sombre avec contraste garanti.

### Ton

- Bienveillant, aspirant (« relation enrichissante »).
- Transparent sur l'IA et le consentement (opt-in entraînement).
- Inclusif (10 langues UI au MVP).

---

## 7. Piliers stratégiques

| Pilier | Description | État réel |
|--------|-------------|-----------|
| **Vitrine & CMS** | Homepage éditable, multilingue, formulaires | 🟡 [module 01](./modules/01-homepage-cms.md) |
| **Onboarding & Sarielle** | Wizard, agent conversationnel | 🟡 [modules 02–03](./modules/02-auth-wizard.md) |
| **Confiance & sécurité** | Vérification, anti-fake, modération | 🟡 [module 06](./modules/06-verification-confiance.md) |
| **Intelligence relationnelle** | AFFINIORA scoring, quiz, suggestions | 🟡 [module 05](./modules/05-affiniora.md) |
| **Cœur produit** | Discover, match, chat temps réel | 🚧 [modules 07–08](./modules/07-discover-matching.md) |
| **Expérience premium** | Abonnements, boost, shop cadeaux | 🔴 [module 09](./modules/09-premium-paiements.md) |
| **Social & engagement** | Live, WebRTC, présence en ligne | 🟡 [modules 10–12](./modules/10-live-streaming.md) |
| **Opérations** | Admin RBAC, KPI, notifications internes | 🟡 [module 15](./modules/15-admin-moderation.md) |
| **Marque & croissance** | Landing, contenu, campagnes | 🚧 (Sarielle) |

*Légende : ✅ opérationnel · 🟡 partiel · 🚧 en cours · 🔴 non opérationnel*

---

## 8. Ambition MVP v1

### Périmètre fonctionnel cible

```
Homepage CMS → Getting Started (wizard) → Sarielle (option)
    → Onboarding + Quiz → Personnalité AFFINIORA → Vérif vidéo
    → Discover (scores réels) → Swipe → Match (confettis) → Chat (WS)
    → Premium · Live · Shop · Blog · Admin · RGPD
```

### Écart code vs opérationnel

| Domaine | Code écrit | Opérationnel bout-en-bout |
|---------|------------|---------------------------|
| Backend API (~20 modules + 4 WS) | ~85 % | ~40 % |
| Frontend (~35 routes) | ~80 % | ~35 % |
| AFFINIORA + Sarielle | ~90 % | ~50 % (si service up) |
| Homepage CMS | ~80 % | ~30 % (sans contenu seed) |
| Tests automatisés | ~15 % couverture utile | — |
| Config prod (Stripe, SMTP, VAPID…) | ~10 % | — |

### Avant production (mi-août 2026)

- Recette manuelle 100 % scénarios P0 ([RECETTE.md](./RECETTE.md))
- Stack dev fiable (`make dev` + Celery + AFFINIORA)
- Configuration services tiers
- Contenu légal + CMS homepage publié
- E2E parcours complet Playwright
- Sign-off staging Sarielle

---

## 9. Critères de succès

### Succès MVP (T0 = lancement)

| Critère | Mesure |
|---------|--------|
| Parcours wizard → match → chat | 100 % fonctionnel en prod |
| Scores AFFINIORA réels sur Discover | Pas de fallback silencieux 65 % |
| Homepage CMS éditable | Mise à jour sans redémarrage |
| Sarielle opérationnelle | Réponses IA, pas mode offline par défaut |
| Paiement premium | ≥ 1 provider actif |
| Admin modération | Signalements + vérifs traitables |
| RGPD | Export + suppression testés |

### Succès produit (3 mois post-launch)

- Onboarding complété > 40 %
- NPS early adopters > 30
- Profils vérifiés > 25 %
- Conversion premium > 2 %

---

## 10. Feuille de route produit

### Phase 1 — MVP v1 (Q2–Q3 2026) ← **nous sommes ici**

- Stabilisation parcours cœur
- Homepage CMS + Sarielle + wizard
- Recette & config tiers
- Launch mi-août 2026

### Phase 2 — Consolidation (Q4 2026)

- Liveness vidéo ML réel
- Apps natives ou PWA avancée
- Dashboard AFFINIORA standalone
- Modèles custom

### Phase 3 — Croissance (2027)

- Expansion géographique
- Features sociales avancées
- Monétisation live étendue

---

## 11. Équipe et gouvernance

| Rôle | Responsable | Périmètre |
|------|-------------|-----------|
| **CEO & PO** | Sarielle | Vision, priorisation, branding, recette, docs produit |
| **Lead Dev** | Lead Dev | Architecture, implémentation, tests auto, déploiement |

> **Sarielle décide quoi et pourquoi. Lead Dev décide comment. Les deux valident le résultat.**

Documents opérationnels : [PLANNING_MVP.md](./PLANNING_MVP.md) · [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md) · [RECETTE.md](./RECETTE.md)

---

## 12. Principes directeurs

1. **Honnêteté sur l'état** — La doc reflète la réalité ([ETAT_AVANCEMENT](./ETAT_AVANCEMENT.md)).
2. **Qualité premium** — Chaque écran mérite la marque AFROMIA.
3. **IA transparente** — Consentement opt-in ; pas de faux scores.
4. **Self-hosted IA** — Souveraineté des données au MVP.
5. **Travailler module par module** — Fiches [docs/modules/](./modules/README.md).
6. **Tester tôt** — Recette Sarielle + E2E avant staging.
7. **Construire ensemble** — Feedback constant binôme fondateur.

---

## 13. Risques et opportunités

### Risques

| Risque | Mitigation |
|--------|------------|
| Écart doc/code vs réalité | ETAT_AVANCEMENT mis à jour chaque sprint |
| AFFINIORA/Celery absents en dev | Automatiser dans `make dev` |
| Charge solo dev | Priorisation stricte par module |
| Paiements non configurés | Sprint S6 dédié |

### Opportunités

- **First mover** premium africain IA-native
- **Sarielle** comme différenciateur relationnel
- **AFFINIORA** comme actif IP B2B
- **CMS homepage** pour SEO et branding agile

---

*Prochaine révision : fin sprint 5 (juillet 2026) ou après sign-off d'un module en recette.*
