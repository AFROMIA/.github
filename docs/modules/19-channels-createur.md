# Module 19 — Channels créateur

**Statut** : 🟡 Partiel (code livré, recette absente)  
**Dépôt** : [SAFIRI](https://github.com/AFROMIA/SAFIRI)

---

## Vision

Espace créateur : chaînes publiques, offres (événements, contenus), abonnements, engagement (likes, commentaires), demandes de contact et monitoring admin.

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Migrations 012, 019–021 | ✅ | channel_events, subscriptions, engagement, inquiries |
| API `channels.py`, engagement, inquiries | ✅ | CRUD + abonnements |
| Admin `admin_channels.py` + WS monitor | ✅ | Backoffice |
| Frontend `/channels`, studio créateur | ✅ | UI complète |
| Checkout offering | 🟡 | Page checkout ; paiement non testé |
| Recette bout-en-bout | ❌ | Aucun sign-off |

## Solution proposée

1. Lancer seed `channel_seed` via Debug Panel ou `make seed`
2. Parcours : créateur seed → studio → publier offering → visiteur s'abonne
3. Tests Playwright : navigation pool channels + checkout mock
4. Modération : workflow admin inquiries

## Compétences requises

- **Backend** : FastAPI, SQLAlchemy, modélisation événements/abonnements
- **Frontend** : Next.js App Router, composants riches (grilles, modales)
- **Produit** : logique créateur/contenu, monétisation offerings
- **Ops** : MinIO pour médias channel si uploads activés

## Fichiers clés (SAFIRI)

- `apps/backend/app/api/v1/channels.py`
- `apps/frontend/src/app/channels/`
- `apps/frontend/src/components/creator/`
