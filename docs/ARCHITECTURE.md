# AFROMIA — Architecture écosystème

> **Démarrage local** : voir [README.md](./README.md) pour lancer SAFIRI et AFFINIORA.

## Vue d'ensemble

L'écosystème AFROMIA est organisé en **deux dépôts applicatifs indépendants**, plus une documentation partagée :

```
AFROMIA/
├── SAFIRI/       # Dépôt app — frontend + backend + packages
├── AFFINIORA/    # Dépôt IA — microservice ai-engine
└── docs/         # Scripts dev, profils env, infra de référence
```

**SAFIRI** et **AFFINIORA** sont des dépôts Git séparés. Ils communiquent uniquement via **API REST** (pas de dépendance de code directe).

## SAFIRI

Monorepo npm (Turborepo) pour l'application de matchmaking :

```
SAFIRI/
├── apps/
│   ├── frontend/     # Next.js 15 PWA
│   └── backend/      # FastAPI async API
├── packages/
│   ├── shared-types/
│   ├── ui/
│   └── config/
├── infra/            # Docker Compose, K8s, CI/CD
└── docs/
```

## AFFINIORA

Dépôt dédié au moteur IA self-hosted (HuggingFace) :

```
AFFINIORA/
├── services/
│   └── ai-engine/    # Scoring, personnalité, anti-fake, traduction
├── infra/
└── docs/
```

## Principes

- **Dépôts séparés** : déploiement et versioning indépendants
- **REST first** + WebSocket (chat temps réel dans SAFIRI)
- **Affiniora** : microservice autonome, contrat API versionné
- **IA 100% self-hosted** : modèles HuggingFace locaux (pas d'OpenAI au MVP)

## Stack

| Couche   | Technologie                              |
|----------|------------------------------------------|
| Backend  | FastAPI + SQLAlchemy 2.0 async + Alembic |
| Frontend | Next.js 15 + Zustand + TanStack Query    |
| AI       | HuggingFace Transformers (AFFINIORA)     |
| DB       | PostgreSQL 16 + PostGIS + pgvector       |
| Cache    | Redis 7 + Celery                         |
| Deploy   | AWS ECS Fargate (Terraform de référence) |

## Flux de données

1. Swipe utilisateur → Backend SAFIRI → score Affiniora (cache Redis) ; au match, Celery calcule le score définitif
2. Match créé → Conversation → WebSocket chat (UI optimiste, typing, accusés de lecture) via Redis Pub/Sub
3. Présence en ligne → WebSocket `/ws/presence` + clés Redis `online:{user_id}`
4. Boutique cadeaux → `/api/v1/shop/*` (virtuel, physique, premium) → messages type `gift` dans le chat
5. Premium → Stripe webhook → rôle utilisateur mis à jour
6. Confidentialité profil → `Profile.visibility` (`public` | `matches_only`)

## Nouveautés temps réel & social (2026)

| Fonctionnalité | Frontend | Backend |
|----------------|----------|---------|
| Chat optimiste | `useChatWebSocket` | `chat_ws.py` + `message.ack` enrichi |
| Indicateur de frappe | `ChatComposer.onTyping` | `ChatService.set_typing` |
| Discover Hub flottant | `DiscoverFloatingHub` | — |
| Affiniora chat | `AffinioraChatTab` | `POST /chat/suggestions/affiniora` |
| Boutique | `/shop`, `GiftShopTab` | `shop.py` + migration `006` |
| Présence admin | `OnlineUsersPanel` | `presence_ws.py`, `GET /admin/online-users` |
| Privacy profil | Settings | `profiles.visibility` |

## Contrat IA v2 & profil enrichi (juin 2026)

| Composant | Rôle |
|-----------|------|
| `UserProfileIA` | Agrégat canonique (quiz, bio, intentions, coaching) — `shared-types/profile-ia.ts` |
| `POST /v1/analyze/profile-full` | Analyse complète AFFINIORA → `ProfileAnalysisReport` |
| `RagService` | Recherche hybride pgvector côté SAFIRI avant appel IA |
| `ia_gating.py` | Limites free/premium (coaching, cloud LLM, aide rédaction) |
| Routeur LLM | Premium + clé cloud → OpenAI/Anthropic ; sinon Qwen local |

Voir [AFFINIORA/docs/CONTRACT_V2.md](../AFFINIORA/docs/CONTRACT_V2.md).

## Channels, wallet & engagement (juin 2026)

| Fonctionnalité | Frontend | Backend |
|----------------|----------|---------|
| Channels créateur | `/channels`, `/creator/studio` | `channels.py`, migrations `012`–`021` |
| Abonnements & engagement | `ChannelsPublicNav` | `channel_engagement.py`, `channel_subscriptions` |
| Demandes contact | panneau inquiry | `channel_inquiries.py` |
| Wallet Safir | `/wallet` | `wallet.py`, `currency.py`, migration `013` |
| Paiements | `/premium/checkout` | Campay, Stripe webhooks |
| Badges | composants `badges/` | `badges.py`, `badge_service.py` |
| Intentions i18n | `IntentionProbeModal` | `intentions.py`, migrations `017`–`018` |
| Speed dating | `/speed-dating` | `speed_dating.py`, WebSocket dédié |

## Outils partagés (docs/)

| Dossier | Rôle |
|---------|------|
| `docs/scripts/` | Bootstrap, dev local, migrations (orchestration multi-dépôts) |
| `docs/env-profiles/` | Templates `.env` (local, docker, supabase) |
| `docs/infra/terraform/` | Terraform AWS de référence |

## Documentation par dépôt

- [Guide développeur local (README)](./README.md)
- [Dépannage](./TROUBLESHOOTING.md)
- [SAFIRI](../SAFIRI/docs/ARCHITECTURE.md)
- [AFFINIORA](../AFFINIORA/docs/ARCHITECTURE.md)
- [Backend SAFIRI](../SAFIRI/apps/backend/docs/ARCHITECTURE.md)
- [Frontend SAFIRI](../SAFIRI/apps/frontend/docs/ARCHITECTURE.md)
- [AI Engine](../AFFINIORA/services/ai-engine/docs/ARCHITECTURE.md)
