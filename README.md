# AFROMIA — Écosystème Safiri & Affiniora

Premium AI-powered matchmaking connecting the world to Africa.

## Structure

```
AFROMIA/
├── SAFIRI/       # Dépôt app (frontend + backend + packages)
├── AFFINIORA/    # Dépôt IA (microservice HuggingFace)
└── docs/         # Scripts dev, profils env, infra de référence
```

Chaque application est un **dépôt Git indépendant**. La communication se fait uniquement via **API REST**.

| Dépôt | Description | Démarrage |
|-------|-------------|-----------|
| [SAFIRI](./SAFIRI/) | Monorepo app (frontend + backend) | `cd SAFIRI && make dev` |
| [AFFINIORA](./AFFINIORA/) | Moteur IA HuggingFace | `cd AFFINIORA && make dev` |

## Dev local (orchestration multi-dépôts)

Les scripts dans `docs/scripts/` coordonnent SAFIRI et AFFINIORA :

| Profil | Base de données | Apps | Commande |
|--------|-----------------|------|----------|
| **local** (recommandé) | Postgres Docker | Backend + Frontend locaux | `docs\start.ps1` |
| **docker** | Postgres Docker | Tout dans Docker | `docs\start.ps1 -Mode docker` |
| **supabase** | Supabase (cloud) | Backend + Frontend locaux | `docs\start.ps1 -Mode supabase` |

### Windows

```powershell
.\docs\start.ps1                    # mode local
.\docs\start.ps1 -Mode docker       # tout dans Docker
.\docs\start.ps1 -Mode bootstrap    # installation seule
```

Double-clic : `docs\start.bat`

Logs centralisés dans `logs/latest.log`.

### Première installation

```powershell
.\docs\scripts\bootstrap.ps1
.\docs\scripts\setup-env.ps1 local
.\docs\scripts\dev.ps1 local
```

### macOS / Linux

```bash
chmod +x docs/scripts/*.sh
./docs/scripts/setup-env.sh local
./docs/scripts/dev.sh local
```

### Supabase + Vercel

1. Créer un projet [Supabase](https://supabase.com)
2. Activer les extensions **postgis** et **vector**
3. `./docs/scripts/setup-env.sh supabase` puis éditer `SAFIRI/.env`
4. `./docs/scripts/dev.sh supabase`
5. Vercel : voir `docs/env-profiles/vercel.env.example`

## Services (dev local)

| Service | URL |
|---------|-----|
| Frontend SAFIRI | http://localhost:3000 |
| Backend API | http://localhost:8000/docs |
| Affiniora AI | http://localhost:8001/docs |
| MinIO | http://localhost:9001 |

## Fixtures de test

| Email | Rôle | Mot de passe |
|-------|------|--------------|
| admin@afromia.com | admin | AdminPassword123! |
| user@afromia.com | user | FixturePass123! |
| premium@afromia.com | premium | FixturePass123! |

Liste complète : [docs/COMPTES_TEST.md](./docs/COMPTES_TEST.md) — seed via `make seed`.

## Documentation

- [Guide développeur local](./docs/README.md) · [Démarrage rapide](./start.md)
- [Comptes de test et fixtures](./docs/COMPTES_TEST.md)
- [Architecture écosystème](./docs/ARCHITECTURE.md)
- [Déploiement AWS](./docs/infra/AWS_DEPLOYMENT.md) · [Pipeline DevOps](./docs/infra/DEVOPS_PIPELINE.md)
- [État d'avancement](./docs/ETAT_AVANCEMENT.md)
- [Contrat API v2 AFFINIORA](./AFFINIORA/docs/CONTRACT_V2.md)
- [Design system & UX romantique](./docs/ux/design.md)
- [SAFIRI](./SAFIRI/docs/ARCHITECTURE.md)
- [AFFINIORA](./AFFINIORA/docs/ARCHITECTURE.md)

## Fonctionnalités récentes

- **Contrat API v2** : `UserProfileIA` comme payload canonique SAFIRI ↔ AFFINIORA ([CONTRACT_V2](./AFFINIORA/docs/CONTRACT_V2.md))
- **Analyse profil IA** : rapport complet, coaching premium, RAG pgvector, gating par tier
- **Sarielle v2** : routeur LLM cloud (premium) / local (Qwen), debug panel IA Lab
- **Channels créateur** : chaînes publiques, abonnements, engagement, demandes de contact
- **Wallet Safir** : monnaie interne, Campay mobile money, checkout Stripe premium
- **Badges & intentions** : catalogue badges, sondes d'intention i18n (10 locales)
- **Speed dating** : sessions live orchestrées (WebSocket + LiveKit)
- **Chat temps réel** : messages instantanés (UI optimiste), indicateur de frappe, accusés de lecture
- **Discover Hub** : panneau flottant (filtres, IA Affiniora, boutique cadeaux)
- **Backoffice** : monitoring channels, badges, intentions, utilisateurs en ligne

## License

Proprietary — AFROMIA Technologies
