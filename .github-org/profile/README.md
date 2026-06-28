# AFROMIA

[![SAFIRI](https://img.shields.io/badge/SAFIRI-Plateforme%20relationnelle-7C3AED?style=for-the-badge&logo=heart)](https://github.com/AFROMIA/SAFIRI)
[![AFFINIORA](https://img.shields.io/badge/AFFINIORA-Moteur%20IA-E11D48?style=for-the-badge&logo=brain)](https://github.com/AFROMIA/AFFINIORA)

**Relations enrichissantes, guidées par l'intelligence.**

AFROMIA conçoit des technologies qui rapprochent les personnes de manière authentique et culturellement ancrée. Notre écosystème combine une plateforme relationnelle moderne (**SAFIRI**), un moteur d'intelligence artificielle dédié (**AFFINIORA**) et l'agent conversationnel **Sarielle**.

---

## Notre mission

Offrir une expérience de rencontre et de connexion humaine où la technologie amplifie la compréhension mutuelle — pas l'inverse. Nous mettons l'accent sur la personnalité, la compatibilité émotionnelle et une approche inclusive ancrée dans les cultures africaines et diasporiques.

---

## Projets

### [SAFIRI](https://github.com/AFROMIA/SAFIRI)

Plateforme relationnelle full-stack : matching, messagerie, live, premium et onboarding guidé.

| Aspect | Détail |
|--------|--------|
| **Frontend** | Next.js 15, TypeScript, Tailwind CSS, next-intl (10 locales) |
| **Backend** | FastAPI, PostgreSQL, Alembic, WebSockets |
| **Fonctionnalités** | Homepage CMS multilingue, wizard Getting Started, découverte, chat, appels vidéo, Sarielle intégré |
| **Déploiement** | Docker, Kubernetes, CI GitHub Actions |

```bash
git clone https://github.com/AFROMIA/SAFIRI.git
cd SAFIRI && cp .env.example .env && make bootstrap && make dev
```

→ Frontend : http://localhost:3000 · API : http://localhost:8000/docs

---

### [AFFINIORA](https://github.com/AFROMIA/AFFINIORA)

Moteur IA self-hosted pour l'analyse de personnalité, le scoring de compatibilité et l'agent Sarielle.

| Aspect | Détail |
|--------|--------|
| **Stack** | FastAPI, HuggingFace, modèles personnalisés |
| **Personnalité** | OCEAN, MBTI, DISC, Ennéagramme, langages de l'amour |
| **Sarielle** | Agent conversationnel multilingue avec politique d'accès progressive |
| **Training** | Pipeline STONE pour fine-tuning sur datasets labellisés |

```bash
git clone https://github.com/AFROMIA/AFFINIORA.git
cd AFFINIORA && cp .env.example .env && make dev
```

→ API : http://localhost:8001/docs

---

## Écosystème produit

```
┌─────────────────────────────────────────────────────────┐
│                      AFROMIA                            │
│                                                         │
│   ┌──────────────┐    ┌──────────────┐                 │
│   │    SAFIRI    │───▶│  AFFINIORA   │                 │
│   │  (plateforme)│    │  (moteur IA) │                 │
│   └──────┬───────┘    └──────┬───────┘                 │
│          │                   │                          │
│          └─────────┬─────────┘                          │
│                    ▼                                    │
│            ┌──────────────┐                             │
│            │   Sarielle   │                             │
│            │ (agent conv.)│                             │
│            └──────────────┘                             │
└─────────────────────────────────────────────────────────┘
```

| Composant | Rôle |
|-----------|------|
| **SAFIRI** | Expérience utilisateur, profils, matching, messagerie |
| **AFFINIORA** | Intelligence : quiz, compatibilité, suggestions, Sarielle |
| **Sarielle** | Guide conversationnel accessible sur la homepage et dans l'app |

---

## Stack technique

- **Langages** : TypeScript, Python 3.11+
- **Frontend** : Next.js, React, Tailwind CSS, Zustand
- **Backend** : FastAPI, SQLAlchemy, Alembic
- **IA** : HuggingFace Transformers, pipelines custom STONE
- **Infra** : Docker, Kubernetes, Prometheus, Nginx
- **Qualité** : pytest, Vitest, Playwright e2e

---

## Contribuer

Les dépôts sont en développement actif (MVP v1, cible production mi-août 2026). Pour contribuer :

1. Forkez le dépôt concerné ([SAFIRI](https://github.com/AFROMIA/SAFIRI) ou [AFFINIORA](https://github.com/AFROMIA/AFFINIORA))
2. Créez une branche `feature/ma-fonctionnalite`
3. Ouvrez une Pull Request avec une description claire

---

## Contact

- **Organisation** : [github.com/AFROMIA](https://github.com/AFROMIA)
- **Site** : *à venir*

---

<p align="center">
  <em>AFROMIA — Des relations enrichissantes, portées par l'intelligence.</em>
</p>
