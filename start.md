# AFROMIA — Démarrage local

Guide pour lancer **SAFIRI** (app de rencontre) et **AFFINIORA** (moteur IA) en développement.

| Produit | URL dev | Dossier |
|---------|---------|---------|
| SAFIRI (frontend) | http://localhost:3000 | `SAFIRI/apps/frontend/` |
| SAFIRI (backend) | http://localhost:8000/docs | `SAFIRI/apps/backend/` |
| AFFINIORA (IA) | http://localhost:8001/docs | `AFFINIORA/` |

Les deux produits communiquent par API REST (`AFFINIORA_API_URL` dans `SAFIRI/.env`).

---

## Prérequis (première fois)

```powershell
cd "C:\Users\MAITRE\Documents\IronCorp technologies\AFROMIA"

make bootstrap    # npm + pip backend SAFIRI
make env-local    # SAFIRI/.env + AFFINIORA/.env
```

- Docker Desktop doit tourner.
- Ouvrir le projet avec la casse exacte du disque : **`AFROMIA`** (pas `Afromia`).

---

## Option A — Un seul terminal (`make dev`)

Tout dans une fenêtre : infra Docker, migrations, backend, frontend et Affiniora.

```powershell
make dev
```

Équivalents :

```powershell
powershell -ExecutionPolicy Bypass -File docs\start.ps1 -Mode local
start.bat          # double-clic Windows
```

**Avantage** : une commande, logs centralisés dans `logs/latest.log`.  
**Inconvénient** : un crash ou reload raté du backend peut couper toute la session.

Sans Affiniora (plus léger) :

```powershell
powershell -ExecutionPolicy Bypass -File docs\start.ps1 -Mode local -SkipAffiniora
```

---

## Option B — Grille 2×2 Windows Terminal (recommandé)

Une commande : **infra dans ce terminal**, puis **4 volets** dans une fenêtre WT maximisée.

```powershell
make dev-split
```

Depuis la racine **AFROMIA/**, **SAFIRI/** ou **AFFINIORA/**.

Équivalent : `start-split.bat` (racine AFROMIA uniquement)

```
┌─────────────────────┬─────────────────────┐
│ Backend   :8000     │ Frontend  :3000     │
├─────────────────────┼─────────────────────┤
│ Affiniora :8001     │ Celery              │
└─────────────────────┴─────────────────────┘
```

- L’infra tourne dans **une fenêtre qui se ferme** automatiquement à la fin
- Puis **4 fenêtres** s’ouvrent (backend, frontend, affiniora, celery)
- Si **Windows Terminal** (`wt`) est installé : grille 2×2 à la place des 4 fenêtres
- Même comportement depuis **AFROMIA/**, **SAFIRI/** ou **AFFINIORA/**

Infra déjà démarrée :

```powershell
make dev-split SKIP_INFRA=1
```

Sans Celery (3 volets) :

```powershell
powershell -File docs\scripts\start-split.ps1 -SkipCelery
```

Fallback sans Windows Terminal : fenêtres PowerShell séparées.

---

## Option C — Terminaux manuels un par un

Utile si vous ne travaillez que sur une brique.

```powershell
# Terminal 1 — infra (obligatoire pour backend)
make dev-infra

# Terminal 2 — backend (optionnel si pas de travail API)
make dev-backend

# Terminal 3 — frontend (optionnel si pas de travail UI)
make dev-frontend

# Terminal 4 — Affiniora (optionnel : Sarielle, quiz, scoring)
make dev-affiniora

# Terminal 5 — Celery (optionnel)
make celery
```

Guides détaillés par composant :

- Backend SAFIRI → [`SAFIRI/apps/backend/start.md`](SAFIRI/apps/backend/start.md)
- Frontend SAFIRI → [`SAFIRI/apps/frontend/start.md`](SAFIRI/apps/frontend/start.md)
- Affiniora → [`AFFINIORA/start.md`](AFFINIORA/start.md)

---

## URLs une fois démarré

| Service | URL | Notes |
|---------|-----|-------|
| App SAFIRI | http://localhost:3000 | PWA |
| API SAFIRI | http://localhost:8000/docs | Swagger |
| API Affiniora | http://localhost:8001/docs | Swagger IA |
| MinIO (médias) | http://localhost:9001 | `minioadmin` / `minioadmin` |
| LiveKit | ws://localhost:7880 | WebRTC |
| Logs session | `logs/latest.log` | Mode `make dev` uniquement |

---

## Commandes utiles

| Commande | Description |
|----------|-------------|
| `make dev-clean` | Purge cache Next.js (erreurs 500 / HMR cassé) |
| `make migrate` | Migrations Alembic |
| `make seed` | Données de test |
| `make down` | Arrête les conteneurs Docker SAFIRI + Affiniora |
| `make help` | Liste toutes les cibles Make |

---

## Dépannage rapide

| Problème | Action |
|----------|--------|
| `localhost:3000` inaccessible après reload backend | Utiliser `make dev-split` ou relancer seulement `make dev-frontend` |
| Erreur 500 Next.js / hooks React | `make dev-clean` puis relancer le frontend |
| Affiniora / Sarielle indisponible | Lancer `make dev-affiniora` (terminal 4) |
| Port 5432 occupé | Le script bascule automatiquement sur 5433+ |
| Docker Hub inaccessible | Voir [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) |

Documentation complète : [`docs/README.md`](docs/README.md) · [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)
