<p align="center">
  <img src="../docs/assets/brand/logo_afromia.png" alt="AFROMIA" width="140" />
</p>

<h1 align="center">AFROMIA</h1>

<p align="center">
  <img src="../docs/assets/brand/logo_safiri.jpeg" alt="SAFIRI Connect" height="48" />
  &nbsp;&nbsp;
  <a href="https://github.com/AFROMIA/AFFINIORA"><img src="https://img.shields.io/badge/AFFINIORA-Moteur%20cognitif-E11D48?style=for-the-badge" alt="AFFINIORA" /></a>
</p>

<p align="center"><strong>Construire aujourd'hui le numérique de l'Afrique de demain.</strong></p>

<p align="center">Infrastructure numérique panafricaine — <strong>SAFIRI Connect</strong> · <strong>AFFINIORA</strong> · <strong>Sarielle</strong></p>

---

## Notre mission

Créer un écosystème numérique intégré qui simplifie la vie des particuliers, des entrepreneurs, des entreprises et des institutions africaines grâce à des solutions innovantes, accessibles et interconnectées.

> [Charte de fondation v1.0](https://github.com/AFROMIA/.github/blob/main/docs/CHARTE_FONDATION.md) · Promoteur : **Bruce SIANI**

---

## Les personnalités de l'écosystème

| Entité | Rôle |
|--------|------|
| **AFROMIA** | Vision, infrastructure, identité |
| **SAFIRI Connect** | Porte d'entrée — connexions intelligentes |
| **AFFINIORA** | Moteur cognitif — le cerveau |
| **Sarielle** | Compagnon numérique personnel — le visage |

---

## État du projet

| Document | Contenu |
|----------|---------|
| [**Charte de fondation**](https://github.com/AFROMIA/.github/blob/main/docs/CHARTE_FONDATION.md) | Vision, rôles, décisions irréversibles, identité |
| [**État d'avancement réel**](https://github.com/AFROMIA/.github/blob/main/docs/ETAT_AVANCEMENT.md) | Matrice modules, bloqueurs, solutions & compétences |
| [Fiches modules (22)](https://github.com/AFROMIA/.github/tree/main/docs/modules) | Détail technique module par module |
| [Guide dev local](https://github.com/AFROMIA/.github/blob/main/docs/README.md) | Installation, URLs, dépannage |
| [Démarrage rapide](https://github.com/AFROMIA/.github/blob/main/start.md) | `make dev` / `make dev-split` |

**Synthèse juillet 2026** : ~90 % backend écrit, ~85 % frontend — recette bout-en-bout ~25 %. Nouveautés : channels créateur, wallet Safir, badges, speed dating, contrat IA v2, Founder Book.

---

## Projets

### [SAFIRI](https://github.com/AFROMIA/SAFIRI) — SAFIRI Connect

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

### [AFFINIORA](https://github.com/AFROMIA/AFFINIORA) — Moteur cognitif

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

## Écosystème

```
┌─────────────────────────────────────────────────────────┐
│                      AFROMIA                            │
│   Identity · Wallet · Vision · Infrastructure         │
│   ┌──────────────┐    ┌──────────────┐                 │
│   │ SAFIRI       │───▶│  AFFINIORA   │                 │
│   │ Connect      │    │  (cerveau)   │                 │
│   └──────┬───────┘    └──────┬───────┘                 │
│          └─────────┬─────────┘                          │
│                    ▼                                    │
│            ┌──────────────┐                             │
│            │   Sarielle   │  compagnon personnel        │
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

1. Lire la [charte de fondation](https://github.com/AFROMIA/.github/blob/main/docs/CHARTE_FONDATION.md)
2. Consulter [l'état d'avancement](https://github.com/AFROMIA/.github/blob/main/docs/ETAT_AVANCEMENT.md)
3. Fork [SAFIRI](https://github.com/AFROMIA/SAFIRI) ou [AFFINIORA](https://github.com/AFROMIA/AFFINIORA)
4. PR avec référence au module concerné

---

<p align="center"><em>AFROMIA — Construire aujourd'hui le numérique de l'Afrique de demain.</em></p>
