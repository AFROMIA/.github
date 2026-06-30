# AFROMIA

[![SAFIRI](https://img.shields.io/badge/SAFIRI-Plateforme%20relationnelle-7C3AED?style=for-the-badge&logo=heart)](https://github.com/AFROMIA/SAFIRI)
[![AFFINIORA](https://img.shields.io/badge/AFFINIORA-Moteur%20IA-E11D48?style=for-the-badge&logo=brain)](https://github.com/AFROMIA/AFFINIORA)

**Relations enrichissantes, guidées par l'intelligence.**

AFROMIA conçoit des technologies qui rapprochent les personnes de manière authentique et culturellement ancrée : plateforme **SAFIRI**, moteur IA **AFFINIORA**, agent **Sarielle**.

---

## Notre mission

Offrir une expérience de rencontre et de connexion humaine où la technologie amplifie la compréhension mutuelle — pas l'inverse. Accent sur la personnalité, la compatibilité émotionnelle et une approche inclusive ancrée dans les cultures africaines et diasporiques.

---

## État du projet

| Document | Contenu |
|----------|---------|
| [**État d'avancement réel**](https://github.com/AFROMIA/.github/blob/main/docs/ETAT_AVANCEMENT.md) | Matrice modules, bloqueurs, **solutions & compétences par fonctionnalité** |
| [Fiches modules (22)](https://github.com/AFROMIA/.github/tree/main/docs/modules) | Détail technique module par module |
| [Guide dev local](https://github.com/AFROMIA/.github/blob/main/docs/README.md) | Installation, URLs, dépannage |
| [Démarrage rapide](https://github.com/AFROMIA/.github/blob/main/start.md) | `make dev` / `make dev-split` |

**Synthèse juin 2026** : ~90 % backend écrit, ~85 % frontend — recette bout-en-bout ~25 %. Nouveautés : channels créateur, wallet Safir, badges, intentions i18n, speed dating, contrat IA v2.

---

## Projets

### [SAFIRI](https://github.com/AFROMIA/SAFIRI) — Plateforme relationnelle

| Aspect | Détail |
|--------|--------|
| **Frontend** | Next.js 15, TypeScript, Tailwind, next-intl (10 locales) |
| **Backend** | FastAPI, PostgreSQL, Alembic, WebSockets |
| **Fonctionnalités** | Discover, chat, channels, wallet, premium, Sarielle |

```bash
git clone https://github.com/AFROMIA/SAFIRI.git
cd SAFIRI && cp .env.example .env && make bootstrap && make dev
```

→ http://localhost:3000 · API http://localhost:8000/docs

### [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) — Moteur IA

| Aspect | Détail |
|--------|--------|
| **Stack** | FastAPI, HuggingFace, routeur LLM cloud/local |
| **v2** | UserProfileIA, coaching, RAG — [CONTRACT_V2](https://github.com/AFROMIA/AFFINIORA/blob/main/docs/CONTRACT_V2.md) |
| **Sarielle** | Agent multilingue, debug panel IaLab |

```bash
git clone https://github.com/AFROMIA/AFFINIORA.git
cd AFFINIORA && cp .env.example .env && make dev
```

→ http://localhost:8001/docs

---

## Fonctionnalités récentes

| Feature | Doc |
|---------|-----|
| Contrat IA v2 | [Module 05](https://github.com/AFROMIA/.github/blob/main/docs/modules/05-affiniora.md) |
| Channels créateur | [Module 19](https://github.com/AFROMIA/.github/blob/main/docs/modules/19-channels-createur.md) |
| Wallet Safir | [Module 20](https://github.com/AFROMIA/.github/blob/main/docs/modules/20-wallet-safir.md) |
| Badges & intentions | [Module 21](https://github.com/AFROMIA/.github/blob/main/docs/modules/21-badges-intentions.md) |
| Speed dating | [Module 22](https://github.com/AFROMIA/.github/blob/main/docs/modules/22-speed-dating.md) |

---

## Écosystème

```
┌─────────────────────────────────────────────────────────┐
│                      AFROMIA                            │
│   ┌──────────────┐    ┌──────────────┐                 │
│   │    SAFIRI    │───▶│  AFFINIORA   │                 │
│   └──────┬───────┘    └──────┬───────┘                 │
│          └─────────┬─────────┘                          │
│                    ▼                                    │
│            ┌──────────────┐                             │
│            │   Sarielle   │                             │
│            └──────────────┘                             │
└─────────────────────────────────────────────────────────┘
```

---

## Dev local & déploiement cloud

| Ressource | Lien |
|-----------|------|
| Dev local | [start.md](https://github.com/AFROMIA/.github/blob/main/start.md) · [docs/scripts/](https://github.com/AFROMIA/.github/tree/main/docs/scripts) |
| **Déploiement AWS** | [**docs/infra/**](https://github.com/AFROMIA/.github/tree/main/docs/infra) · [guide complet](https://github.com/AFROMIA/.github/blob/main/docs/infra/AWS_DEPLOYMENT.md) |
| CI/CD | [Pipeline DevOps](https://github.com/AFROMIA/.github/blob/main/docs/infra/DEVOPS_PIPELINE.md) |

```powershell
# Staging AWS (après IAM configuré)
cd docs/infra/scripts
.\bootstrap-aws.ps1 -Profile afromia-dev
.\deploy-staging.ps1 -Profile afromia-dev
```

---

## Contribuer

1. Consulter [l'état d'avancement](https://github.com/AFROMIA/.github/blob/main/docs/ETAT_AVANCEMENT.md)
2. Fork [SAFIRI](https://github.com/AFROMIA/SAFIRI) ou [AFFINIORA](https://github.com/AFROMIA/AFFINIORA)
3. PR avec référence au module concerné

---

<p align="center"><em>AFROMIA — Des relations enrichissantes, portées par l'intelligence.</em></p>
