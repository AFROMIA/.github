# AFROMIA — Document de vision produit

**Version** : 3.0  
**Date** : 9 juillet 2026  
**Statut** : MVP v1 — stabilisation, déploiement AWS staging, recette  
**Cible production** : mi-août 2026  

**Documents liés** : [**Charte de fondation**](./CHARTE_FONDATION.md) · [Spécification](./SPECIFICATION_FONCTIONNELLE.md) · [État](./ETAT_AVANCEMENT.md) · [Recette](./RECETTE.md) · [Modules](./modules/README.md) · [Planning](./PLANNING_MVP.md) · [Infra AWS](./infra/README.md)

**Dépôts Git** : [SAFIRI](https://github.com/AFROMIA/SAFIRI) · [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) · [Docs `.github`](https://github.com/AFROMIA/.github)

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

**AFROMIA** est une **plateforme d'infrastructure numérique panafricaine** : vision, identité, gouvernance et fondations technologiques pour un écosystème de produits interconnectés, avec une identité **africaine moderne, internationale et futuriste**.

Quatre entités nommées distinctement (voir [Charte de fondation](./CHARTE_FONDATION.md)) :

| Nom | Rôle |
|-----|------|
| **AFROMIA** | Société — vision, infrastructure, identité unique, wallet |
| **SAFIRI Connect** | Porte d'entrée — connexions intelligentes (personnes, communautés, opportunités) |
| **AFFINIORA** | Moteur cognitif — affinités, recommandations, orchestration (le cerveau) |
| **Sarielle** | Compagnon numérique personnel — accompagnement, coaching, interface humaine d'Affiniora |

Le MVP v1 combine swipe, messagerie temps réel, homepage CMS multilingue, wizard d'inscription, fonctionnalités premium, live, boutique cadeaux et backoffice admin.

> **État réel (juin 2026)** : base de code **vaste** + **documentation et scripts sur Git** ([`.github`](https://github.com/AFROMIA/.github)). Nouveaux chantiers : channels, wallet, IA v2, **pipeline AWS staging** (Terraform 79 ressources, scripts deploy). Voir [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md).

La phase en cours : **stabilisation**, **déploiement staging AWS**, **recette**, **configuration tiers**, **onboarding contributeurs** (accès GitHub).

---

## 2. Mission et vision

### Mission

Créer un **écosystème numérique intégré** qui simplifie la vie des particuliers, des entrepreneurs, des entreprises et des institutions africaines grâce à des solutions innovantes, accessibles et interconnectées.

### Vision (3–5 ans)

> *« Construire l'infrastructure numérique qui permettra à chaque Africain de se connecter, créer, apprendre, entreprendre, commercer, investir et prospérer, grâce à des technologies conçues par l'Afrique et pour l'Afrique. »*

**Devise** : *Construire aujourd'hui le numérique de l'Afrique de demain.*

Devenir une **référence internationale d'innovation numérique africaine**, reconnue pour :

- la **qualité des connexions** (Opportunity Graph + AFFINIORA, pas seulement l'apparence) ;
- la **confiance** (profils vérifiés, Trust Engine, transparence IA) ;
- l'**expérience utilisateur** au niveau des meilleures apps lifestyle ;
- un **écosystème IA propriétaire** (AFFINIORA + Sarielle) réutilisable sur d'autres verticales.

### Énoncé vision produit (SAFIRI Connect)

> *« Un écosystème relationnel premium, chaleureux et intelligent, qui connecte le monde à l'Afrique moderne — une **relation enrichissante**. »*

SAFIRI n'est ni un réseau social classique ni un simple site de rencontre : c'est la **plateforme panafricaine de connexions intelligentes** (l'amour n'est qu'un cas d'usage).

---

## 3. Écosystème produit & naming

```
┌─────────────────────────────────────────────────────────────────┐
│                     AFROMIA (société)                           │
│     Vision · Infrastructure · Identity · Wallet · Gouvernance   │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  SAFIRI Connect │  │   AFFINIORA     │  │ Afromia Identity│
│  Porte d'entrée │◄►│  Moteur cognitif│  │  (SSO futur)    │
│  Next.js+FastAPI│  │  FastAPI + HF   │  └─────────────────┘
└────────┬────────┘  └────────┬────────┘
         │                    │
         │                    ▼
         │             ┌─────────────┐
         └────────────►│  Sarielle   │  compagnon personnel (gratuit)
                       │  (visage IA)│
                       └─────────────┘
         │  Postgres · Redis · MinIO · Celery
         └───────────────────┬───────────────────
                             ▼
                    Infrastructure cloud (AWS / Vercel)
```

| Composant | Rôle | Interface |
|-----------|------|-----------|
| **AFROMIA** | Société, marque, infrastructure, docs | [Charte](./CHARTE_FONDATION.md) |
| **SAFIRI Connect** | App principale (PWA), discover, chat, premium, channels | Web mobile-first |
| **AFFINIORA** | Scoring, personnalité, anti-fake, orchestration | API REST |
| **Sarielle** | Coach personnel, navigation, accompagnement relationnel/pro | `/sarielle`, hub flottant |
| **docs/** | Documentation, scripts dev, Terraform AWS, recette | Équipe — [github.com/AFROMIA/.github](https://github.com/AFROMIA/.github) |

**Principe** : dépôts applicatifs indépendants, **REST + WebSocket**, communication inter-produits par **API versionnées**, **IA 100 % self-hosted** au MVP.

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

**Bruce SIANI** — Promoteur & fondateur. Vision, Founder Book, priorisation, branding, recette.

**Lead Dev** — Full Stack. SAFIRI, AFFINIORA, infra, tests, déploiement.

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
| **Expérience premium** | Abonnements, wallet Safir, channels, shop | 🟡 [modules 09, 19–20](./modules/09-premium-paiements.md) |
| **Social & engagement** | Live, WebRTC, speed dating, badges | 🟡 [modules 10–12, 21–22](./modules/10-live-streaming.md) |
| **Opérations & cloud** | Admin, déploiement AWS ECS, CI/CD | 🚧 [module 18](./modules/18-infra-devops.md) |
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
- Sign-off staging Promoteur

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
| **Promoteur & fondateur** | Bruce SIANI | Vision, Founder Book, priorisation, branding, recette, docs produit |
| **Lead Dev** | Équipe technique | Architecture, implémentation, tests auto, déploiement |

> **Le Promoteur décide quoi et pourquoi. Le Lead Dev décide comment. Les deux valident le résultat.**

Documents opérationnels : [CHARTE_FONDATION.md](./CHARTE_FONDATION.md) · [PLANNING_MVP.md](./PLANNING_MVP.md) · [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md) · [RECETTE.md](./RECETTE.md)

---

## 12. Principes directeurs

1. **Honnêteté sur l'état** — [ETAT_AVANCEMENT](./ETAT_AVANCEMENT.md) mis à jour chaque sprint.
2. **Doc sur Git** — Pas de savoir piégé sur une machine ; onboarding via [README](./README.md).
3. **Qualité premium** — Chaque écran mérite la marque AFROMIA.
4. **IA transparente** — Consentement opt-in ; pas de faux scores.
5. **Self-hosted IA** — Souveraineté des données au MVP.
6. **Travailler module par module** — Fiches [docs/modules/](./modules/README.md).
7. **Tester tôt** — Recette Promoteur + E2E avant staging.
8. **Construire ensemble** — Contributeurs via GitHub ; doc à jour sur `.github`.

---

## 13. Risques et opportunités

### Risques

| Risque | Mitigation |
|--------|------------|
| Écart doc/code vs réalité | ETAT_AVANCEMENT mis à jour chaque sprint |
| AFFINIORA/Celery absents en dev | `make dev-split` documenté |
| IAM AWS bloquant staging | [IAM_BLOCKER](./infra/IAM_BLOCKER.md) |
| Charge solo dev | Priorisation par module + accès GitHub contributeurs |
| Paiements non configurés | Sprint S6 dédié |

### Opportunités

- **First mover** premium africain IA-native
- **Sarielle** comme différenciateur relationnel
- **AFFINIORA** comme actif IP B2B
- **CMS homepage** pour SEO et branding agile

---

*Prochaine révision : fin sprint 5 (juillet 2026) ou après sign-off d'un module en recette.*
