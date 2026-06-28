# AFROMIA — Planning MVP v1

**Version** : 1.0  
**Date** : 19 juin 2026  
**Objectif production** : **15 août 2026** (mi-août)  
**Durée restante** : ~8 semaines  

**Documents liés** : [VISION.md](./VISION.md) · [SPECIFICATION_FONCTIONNELLE.md](./SPECIFICATION_FONCTIONNELLE.md) · [ETAT_AVANCEMENT.md](./ETAT_AVANCEMENT.md)

---

## Table des matières

1. [Objectif du planning](#1-objectif-du-planning)
2. [Équipe et répartition des rôles](#2-équipe-et-répartition-des-rôles)
3. [Matrice RACI simplifiée](#3-matrice-raci-simplifiée)
4. [Vue d'ensemble des sprints](#4-vue-densemble-des-sprints)
5. [Calendrier](#5-calendrier)
6. [Détail par sprint](#6-détail-par-sprint)
7. [Jalons (milestones)](#7-jalons-milestones)
8. [Backlog transversal](#8-backlog-transversal)
9. [Stratégie de test](#9-stratégie-de-test)
10. [Checklist go-live](#10-checklist-go-live)
11. [Suivi hebdomadaire (template)](#11-suivi-hebdomadaire-template)

---

## 1. Objectif du planning

Livrer le **MVP v1 full spec** de SAFIRI + AFFINIORA en production mi-août 2026, avec :

- un parcours utilisateur complet et stable ;
- l'IA Affiniora intégrée et visible ;
- la monétisation premium opérationnelle ;
- la modération et la conformité RGPD en place ;
- une identité de marque cohérente et un plan de lancement initial.

**État au 19 juin 2026** : sprints 1 à 4 **livrés côté code** (~85 % du MVP). Sprints 5 à 8 = **durcissement, config, recette, déploiement, marketing**.

---

## 2. Équipe et répartition des rôles

### Binôme fondateur

| | **Sarielle — CEO & Product Owner** | **Lead Dev — Full Stack & Prompt Engineering** |
|---|-----------------------------------|--------------------------------------------------|
| **Mission** | Porter la vision, prioriser, valider le produit | Construire et déployer la stack technique |
| **Produit** | Roadmap, user stories, priorisation backlog | Estimation technique, implémentation |
| **Design & branding** | Direction créative, charte, copywriting, assets | Intégration UI, design system |
| **Marketing** | Stratégie GTM, réseaux sociaux, landing copy | SEO technique, perf, analytics |
| **Documentation** | Vision, specs, contenus CMS/légaux | README, architecture, scripts dev |
| **Tests** | Recette fonctionnelle, parcours utilisateur | Tests auto (pytest, Playwright), fixes |
| **Gestion de projet** | Planning, suivi sprint, communication | Exécution technique, démo fin de sprint |
| **IA / prompts** | Validation qualité suggestions & UX IA | Prompts Affiniora, tuning scoring, Celery |

### Principe de collaboration

> **Sarielle décide quoi et pourquoi. Lead Dev décide comment. Les deux valident le résultat.**

- Sarielle teste **chaque fin de sprint** sur un environnement stable (staging).
- Lead Dev corrige les bugs bloquants en priorité sur retour Sarielle.
- Pas de nouvelle feature majeure après le **21 juillet 2026** (freeze scope).

---

## 3. Matrice RACI simplifiée

Légende : **R** = Responsible · **A** = Accountable · **C** = Consulted · **I** = Informed

| Activité | Sarielle | Lead Dev |
|----------|----------|----------|
| Vision & positionnement | **A/R** | C |
| Spécifications fonctionnelles | **A/R** | C |
| Développement backend/frontend | I | **A/R** |
| Prompts & tuning AFFINIORA | C | **A/R** |
| Branding & identité visuelle | **A/R** | C |
| Contenu marketing & landing | **A/R** | C |
| Pages légales (CGU, Privacy) | **A/R** | I |
| Recette fonctionnelle | **A/R** | C |
| Tests automatisés E2E | C | **A/R** |
| Config Stripe/PayPal/LiveKit | I | **A/R** |
| Déploiement production | C | **A/R** |
| Modération & support launch | **A/R** | C |
| Go/no-go production | **A** (joint) | **A** (joint) |

---

## 4. Vue d'ensemble des sprints

| Sprint | Période | Thème | Statut |
|--------|---------|-------|--------|
| **S1** | Sem. 1–2 (mai) | AFFINIORA + Discover (scores réels, quiz, Celery) | ✅ Livré |
| **S2** | Sem. 3–4 (mai–juin) | Vérification vidéo, sécurité, premium features | ✅ Livré |
| **S3** | Sem. 5–6 (juin) | WebRTC, chat enrichi, PayPal, push | ✅ Livré |
| **S4** | Sem. 7–8 (juin) | Live, CMS, shop, KPI admin, E2E smoke | ✅ Livré |
| **S5** | 23 juin – 6 juil. | Stabilisation, recette Sarielle, bugs critiques | 🔵 En cours |
| **S6** | 7 – 20 juil. | Config services tiers + durcissement sécurité | ⬜ Planifié |
| **S7** | 21 juil. – 3 août | Staging, perf, E2E complets, contenu légal | ⬜ Planifié |
| **S8** | 4 – 15 août. | Prod deploy, monitoring, lancement marketing | ⬜ Planifié |

---

## 5. Calendrier

```
2026
Juin    │ S4 fin ████ │ S5 début ████
        │ 19 juin = aujourd'hui
────────┼────────────────────────────────────────
Juil    │ S5 ████████ │ S6 ████████ │ S7 ████████
        │              │ 21 juil = FREEZE SCOPE
────────┼────────────────────────────────────────
Août    │ S7 ████ │ S8 ████████ │ 🚀 15 août LAUNCH
```

### Dates clés

| Date | Jalon |
|------|-------|
| **19 juin 2026** | Fin dev features MVP (code base) |
| **6 juillet 2026** | Fin recette S5 — backlog bugs P0 vide |
| **20 juillet 2026** | Stripe/PayPal/LiveKit/VAPID configurés |
| **21 juillet 2026** | **Freeze scope** — plus de nouvelles features |
| **3 août 2026** | Staging validé par Sarielle (sign-off recette) |
| **10 août 2026** | Soft launch interne / beta fermée |
| **15 août 2026** | **Launch public MVP v1** |

---

## 6. Détail par sprint

### Sprint 1 — AFFINIORA + Discover ✅

**Objectif** : Brancher l'IA réelle sur le cœur produit (discover + personnalité).

| Tâche | Responsable | Livrable |
|-------|-------------|----------|
| Intégration AffinioraClient + cache Redis | Lead Dev | Scores réels feed |
| Quiz onboarding → Celery → personality | Lead Dev | `/personality` fonctionnel |
| Filtres Discover (distance PostGIS, langue) | Lead Dev | `DiscoverFilterPanel` |
| UI breakdown score sur cartes | Lead Dev | `SwipeCardStack` |
| Suggestions IA chat | Lead Dev | `ChatComposer` |
| Recette parcours quiz → discover | Sarielle | Rapport bugs |

---

### Sprint 2 — Vérification & sécurité ✅

**Objectif** : Confiance utilisateur et modération.

| Tâche | Responsable | Livrable |
|-------|-------------|----------|
| API + UI vérification vidéo | Lead Dev | `/verify-video` |
| Gate Discover `is_verified` | Lead Dev | Config backend |
| Blocage / signalement | Lead Dev | Profil public |
| Admin modération + vérif vidéo | Lead Dev | Panel admin |
| Likes limités, visiteurs, boost | Lead Dev | Premium features |
| Rédaction copy confiance / sécurité | Sarielle | Textes UI + CMS |
| Test parcours signalement | Sarielle | Validation workflow |

---

### Sprint 3 — WebRTC, chat, monétisation ✅

**Objectif** : Engagement post-match et revenus.

| Tâche | Responsable | Livrable |
|-------|-------------|----------|
| Signaling WS + coturn | Lead Dev | Appels vidéo |
| `VideoCallModal` WebRTC | Lead Dev | UI chat |
| Messages image S3 | Lead Dev | Upload chat |
| Push notifications PWA | Lead Dev | Backend push |
| PayPal abonnements | Lead Dev | `/premium` |
| Copy premium & pricing | Sarielle | Page `/premium` |
| Test appel vidéo 2 comptes | Sarielle | Recette |

---

### Sprint 4 — Live, CMS, shop, admin ✅

**Objectif** : Écosystème social complet + ops.

| Tâche | Responsable | Livrable |
|-------|-------------|----------|
| Live sessions + WS commentaires | Lead Dev | `/live` |
| CMS pages/blog TipTap | Lead Dev | `/blog`, `/legal` |
| Boutique cadeaux | Lead Dev | `/shop` |
| KPI dashboard admin | Lead Dev | `/admin` |
| E2E smoke Playwright | Lead Dev | `mvp.spec.ts` |
| Contenu blog initial (3 articles) | Sarielle | CMS publié |
| Pages légales brouillon | Sarielle | Slugs CMS |

---

### Sprint 5 — Stabilisation & recette 🔵 (23 juin – 6 juil.)

**Objectif** : Produit testable de bout en bout par Sarielle sans blocage.

#### Lead Dev

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Fix bugs remontés S1–S4 | P0 | 3 j |
| `make dev` stable (logs centralisés Affiniora) | P1 | 0.5 j |
| Documenter runbook Celery + Affiniora | P1 | 0.5 j |
| Corriger régressions Discover / chat WS | P0 | 2 j |
| Améliorer seed data pour recette Sarielle | P2 | 1 j |

#### Sarielle

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Recette complète parcours happy path | P0 | 2 j |
| Recette admin (modération, KPI, vérif) | P0 | 1 j |
| Liste bugs P0/P1/P2 dans Notion/Sheet | P0 | continu |
| Validation copy onboarding + discover | P1 | 1 j |
| Brief branding assets launch | P1 | 1 j |

**Definition of Done S5** : Sarielle complète le parcours inscription → match → chat sans bug bloquant.

---

### Sprint 6 — Config tiers & sécurité ⬜ (7 – 20 juil.)

**Objectif** : Tous les services externes configurés en staging.

#### Lead Dev

| Tâche | Priorité |
|-------|----------|
| Stripe checkout + webhooks staging/prod | P0 |
| PayPal subscribe + webhooks | P1 |
| SMTP emails vérification | P0 |
| VAPID push notifications | P1 |
| LiveKit tokens (si live MVP) | P2 |
| Rate limiting + headers sécurité | P1 |
| Review secrets / .env prod | P0 |

#### Sarielle

| Tâche | Priorité |
|-------|----------|
| Rédaction CGU + Privacy Policy final | P0 |
| Publication pages légales CMS | P0 |
| Validation emails (ton, branding) | P1 |
| Test achat premium staging | P0 |
| Préparation FAQ support launch | P1 |

**Definition of Done S6** : Paiement test réussi en staging ; emails transactionnels reçus.

---

### Sprint 7 — Staging, perf, E2E ⬜ (21 juil. – 3 août)

**Objectif** : Environnement staging miroir prod, sign-off recette.

#### Lead Dev

| Tâche | Priorité |
|-------|----------|
| Deploy staging (AWS/Vercel ou équivalent) | P0 |
| E2E Playwright parcours complet | P0 |
| Perf Discover + Affiniora (cache, timeouts) | P1 |
| Monitoring Sentry + Prometheus prod | P1 |
| Backup DB + plan rollback | P0 |
| **Freeze scope — bugs only** | — |

#### Sarielle

| Tâche | Priorité |
|-------|----------|
| Recette complète sur staging | P0 |
| Sign-off recette écrit | P0 |
| Landing page copy final | P0 |
| 5 assets marketing (visuels, posts) | P1 |
| Plan beta fermée (50 users) | P1 |

**Definition of Done S7** : Sign-off Sarielle + E2E green + staging stable 48h.

---

### Sprint 8 — Production & lancement ⬜ (4 – 15 août)

**Objectif** : Mise en production et lancement public.

#### Lead Dev

| Tâche | Date cible |
|-------|------------|
| Deploy production | 4–7 août |
| Smoke tests prod | 7 août |
| Monitoring alertes actives | 7 août |
| Hotfix buffer | 8–14 août |

#### Sarielle

| Tâche | Date cible |
|-------|------------|
| Beta fermée (feedback 50 users) | 8–10 août |
| Campagne teasing réseaux sociaux | 1–14 août |
| Communiqué launch | 15 août |
| Modération active J+1 à J+7 | 15–22 août |

**Definition of Done S8** : App accessible publiquement, premium achetable, support Sarielle opérationnel.

---

## 7. Jalons (milestones)

| # | Jalon | Date | Critère de validation |
|---|-------|------|----------------------|
| M1 | Code MVP feature-complete | 19 juin 2026 | ✅ Tous modules SPEC implémentés |
| M2 | Recette interne OK | 6 juil. 2026 | 0 bug P0 ouvert |
| M3 | Services tiers configurés | 20 juil. 2026 | Paiement + email test OK |
| M4 | Sign-off staging | 3 août 2026 | Sarielle signe recette |
| M5 | Beta fermée | 10 août 2026 | 50 users, feedback collecté |
| M6 | **Launch public** | **15 août 2026** | Prod stable, marketing actif |

---

## 8. Backlog transversal

Tâches continues sur plusieurs sprints :

| Item | Owner | Sprint(s) |
|------|-------|-----------|
| Mise à jour SPEC + VISION | Sarielle | S5–S8 |
| Prompt tuning Affiniora (suggestions, scoring) | Lead Dev | S5–S6 |
| Contenu CMS (blog, FAQ, legal) | Sarielle | S5–S7 |
| Tests E2E extension | Lead Dev | S5–S7 |
| Branding assets (logo, OG images, favicon) | Sarielle | S5–S6 |
| Analytics (Plausible/GA) | Lead Dev | S7 |
| Terraform / infra prod | Lead Dev | S6–S7 |

---

## 9. Stratégie de test

### Pyramide de tests MVP

```
        ┌─────────────┐
        │  Recette    │  Sarielle — parcours manuels
        │  manuelle   │  chaque fin de sprint
        ├─────────────┤
        │  E2E        │  Lead Dev — Playwright
        │  Playwright │  smoke → parcours complet S7
        ├─────────────┤
        │  API / unit │  Lead Dev — pytest backend
        └─────────────┘
```

### Parcours de recette Sarielle (checklist)

- [ ] Inscription email + onboarding complet
- [ ] Quiz 12 questions → page personnalité (résultat IA)
- [ ] Vérification vidéo → statut pending → admin approve
- [ ] Discover : filtres, scores visibles, swipe
- [ ] Match → chat temps réel → suggestion IA
- [ ] Envoi cadeau virtuel
- [ ] Achat premium (staging)
- [ ] Blocage + signalement → résolution admin
- [ ] Export RGPD + suppression compte test
- [ ] Pages `/legal/cgu`, `/legal/privacy`
- [ ] Blog accessible
- [ ] Live session (si LiveKit configuré)
- [ ] Appel vidéo (2 navigateurs)

---

## 10. Checklist go-live

### Technique (Lead Dev)

- [ ] Migrations Alembic appliquées prod
- [ ] AFFINIORA ai-engine deployé et healthy
- [ ] Celery worker + beat prod
- [ ] MinIO/S3 prod + CDN médias
- [ ] Redis prod
- [ ] Postgres prod (backups auto)
- [ ] SSL/TLS actif
- [ ] Variables env prod sécurisées (pas de secrets git)
- [ ] Stripe/PayPal webhooks prod
- [ ] SMTP prod
- [ ] Sentry / monitoring
- [ ] Rate limiting actif

### Produit & legal (Sarielle)

- [ ] CGU publiées et linkées footer
- [ ] Privacy Policy publiée
- [ ] Page contact / support
- [ ] Pricing premium validé
- [ ] Copy landing finalisé
- [ ] Plan modération J+7
- [ ] FAQ publique

### Marketing (Sarielle)

- [ ] Identité visuelle cohérente (favicon, OG)
- [ ] Comptes réseaux sociaux prêts
- [ ] 3 posts pré-launch programmés
- [ ] Communiqué launch rédigé
- [ ] Liste beta testers contactée

---

## 11. Suivi hebdomadaire (template)

À remplir chaque lundi (15 min).

```markdown
## Semaine du __/__/2026

### Sarielle
- Fait :
- En cours :
- Bloqué :
- Priorité semaine :

### Lead Dev
- Fait :
- En cours :
- Bloqué :
- Priorité semaine :

### Métriques
- Bugs P0 ouverts : __
- Bugs P1 ouverts : __
- % recette checklist : __%
- Confiance launch (1–5) : __
```

---

## Synthèse charge estimée

| Période | Lead Dev | Sarielle |
|---------|----------|----------|
| S5 (2 sem.) | ~60 h dev/fix | ~25 h recette + doc |
| S6 (2 sem.) | ~50 h config + sécu | ~20 h legal + contenu |
| S7 (2 sem.) | ~50 h staging + E2E | ~25 h recette + marketing |
| S8 (2 sem.) | ~40 h deploy + hotfix | ~30 h launch + modération |
| **Total** | **~200 h** | **~100 h** |

> Planning réaliste pour un binôme motivé à temps plein ou équivalent sur 8 semaines.

---

*Prochaine mise à jour : fin sprint 5 (6 juillet 2026).*
