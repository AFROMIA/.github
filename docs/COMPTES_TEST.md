# Comptes de test et fixtures AFROMIA

Aide-mémoire pour le développement local : connexions, comptes seed, rôles RBAC et données pré-chargées.

**Source de vérité (code)** : [`SAFIRI/apps/backend/app/dev/fixtures/data.py`](../SAFIRI/apps/backend/app/dev/fixtures/data.py)

> Ce fichier est un résumé. En cas de divergence, `data.py` fait foi.

---

## Chargement rapide

```powershell
# Depuis la racine AFROMIA/
make migrate           # alembic upgrade head
make seed              # charge les fixtures (idempotent)
make fixtures-status   # état du seed
make fixtures-reset    # supprime les users @afromia.com
```

Le seed est aussi lancé automatiquement par `make dev` (sauf `-SkipSeed`).

Équivalent direct :

```powershell
cd SAFIRI\apps\backend
python scripts/seed_data.py          # seed
python scripts/seed_data.py status
python scripts/seed_data.py reset
```

---

## URLs et connexions locales

| Service | URL / host | Identifiants |
|---------|------------|--------------|
| **SAFIRI** (app) | http://localhost:3000 | Comptes seed (voir ci-dessous) |
| **Backend API** | http://localhost:8000 | Swagger : http://localhost:8000/docs |
| **Admin backoffice** | http://localhost:3000/admin | `admin@afromia.com` |
| **WebSocket** | ws://localhost:8000 | — |
| **AFFINIORA AI** | http://localhost:8001/docs | — |
| **PostgreSQL** | `localhost:5432` | user `afromia` / pass `afromia` / DB `afromia` |
| **Redis SAFIRI** | `localhost:6379` | DB 0 (app), 1 (Celery broker), 2 (results) |
| **Redis AFFINIORA** | `localhost:6380` | (Docker AFFINIORA) |
| **MinIO S3 API** | http://localhost:9000 | — |
| **MinIO Console** | http://localhost:9001 | `minioadmin` / `minioadmin` |
| **Grafana** | http://localhost:3001 | — |
| **Prometheus** | http://localhost:9090 | — |
| **TURN/STUN** | `turn:localhost:3478` | `afromia` / `afromia-turn-secret` |

### Variables d'environnement clés

```env
DATABASE_URL=postgresql+asyncpg://afromia:afromia@localhost:5432/afromia
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_FRONTEND_URL=http://localhost:3000
AFFINIORA_API_URL=http://localhost:8001
S3_ENDPOINT_URL=http://localhost:9000
S3_BUCKET_NAME=afromia-media-dev
REDIS_URL=redis://localhost:6379/0
```

---

## Mots de passe

| Mot de passe | Comptes concernés |
|--------------|-------------------|
| `AdminPassword123!` | `admin@afromia.com` uniquement |
| `FixturePass123!` | Tous les autres comptes `@afromia.com` |

---

## Hiérarchie des rôles (RBAC)

Définie dans [`SAFIRI/apps/backend/app/domain/rbac.py`](../SAFIRI/apps/backend/app/domain/rbac.py).

```mermaid
flowchart BT
    user[user level 10]
    premium[premium level 20]
    moderator[moderator level 40]
    admin[admin level 60]
    superAdmin[super_admin level 80]
    user --> premium --> moderator --> admin --> superAdmin
```

| Rôle | Niveau | Hérite de | Backoffice | Permissions clés |
|------|--------|-----------|------------|------------------|
| `user` | 10 | — | Non | profil, discovery, swipe, match, chat |
| `premium` | 20 | user | Non | + filtres premium, passport, superlike, boost, likes illimités |
| `moderator` | 40 | premium | **Oui** | + modération contenu, signalements |
| `admin` | 60 | moderator | **Oui** | + stats, URLs, Affiniora admin, suspendre users |
| `super_admin` | 80 | admin | **Oui** | + RBAC, config système |

> Aucun compte seed pour le rôle `super_admin`. Seul `admin@afromia.com` couvre l'administration.

---

## Comptes spéciaux

| Email | Mot de passe | Rôle | Statut | Cas d'usage |
|-------|--------------|------|--------|-------------|
| `admin@afromia.com` | `AdminPassword123!` | admin | active | Backoffice `/admin`, stats, Affiniora, gestion users |
| `moderator@afromia.com` | `FixturePass123!` | moderator | active | Modération contenu, signalements |
| `premium@afromia.com` | `FixturePass123!` | premium | active | Abonnement actif, live, studio créateur |
| `user@afromia.com` | `FixturePass123!` | user | active | Profil principal « Amina Okafor », match avec amara |
| `suspended@afromia.com` | `FixturePass123!` | user | **suspended** | Test suspension de compte |
| `archived@afromia.com` | `FixturePass123!` | user | **archived** | Test archivage de compte |

---

## Profils Discover (22 comptes user)

Tous : mot de passe `FixturePass123!`, rôle `user`, statut `active`.

| Email | Nom affiché | Ville |
|-------|-------------|-------|
| `amara@afromia.com` | Amara Ndiaye | Abidjan |
| `kwame@afromia.com` | Kwame Asante | Kumasi |
| `zara@afromia.com` | Zara Ibrahim | Cairo |
| `malik@afromia.com` | Malik Sow | Bamako |
| `nia@afromia.com` | Nia Osei | Nairobi |
| `thabo@afromia.com` | Thabo Mokoena | Johannesburg |
| `leila@afromia.com` | Leila Benali | Casablanca |
| `emeka@afromia.com` | Emeka Okonkwo | Abuja |
| `selam@afromia.com` | Selam Tesfaye | Addis Ababa |
| `ibrahim@afromia.com` | Ibrahim Diallo | Conakry |
| `folake@afromia.com` | Folake Adeyemi | Ibadan |
| `david@afromia.com` | David Kamau | Mombasa |
| `aisha@afromia.com` | Aisha Moussa | Dar es Salaam |
| `yannick@afromia.com` | Yannick Nguema | Libreville |
| `chidi@afromia.com` | Chidi Eze | Enugu |
| `rudo@afromia.com` | Rudo Moyo | Harare |
| `salma@afromia.com` | Salma Hassan | Khartoum |
| `pierre@afromia.com` | Pierre Nkrumah | Douala |
| `ada@afromia.com` | Ada Okeke | Port Harcourt |
| `moussa@afromia.com` | Moussa Ba | Saint-Louis |
| `grace@afromia.com` | Grace Nkurunziza | Kigali |
| `tendai@afromia.com` | Tendai Mhlanga | Bulawayo |

**Total : 24 emails uniques** (`@afromia.com`).

---

## Données seedées

En plus des comptes, le seed charge :

| Donnée | Détail |
|--------|--------|
| Intérêts | 20 |
| Langues | 12 |
| Questions quiz | 40 |
| Modèle IA | `affiniora-default` v1.0.0 |

### Matchs (2)

| Compte A | Compte B | Score | Détail |
|--------|--------|-------|--------|
| `user@afromia.com` | `amara@afromia.com` | **87.5** | personality 92, interests 85, communication 88, values 84 |
| `premium@afromia.com` | `kwame@afromia.com` | **79.0** | personality 75, interests 82, communication 80, values 78 |

### Swipes (6)

| Swiper | Swipé | Action |
|--------|-------|--------|
| user | amara | like |
| amara | user | like |
| user | kwame | dislike |
| premium | kwame | like |
| kwame | premium | like |
| moderator | user | like |

### Conversations (2)

**user ↔ amara** (3 messages) :

1. user : « Salut Amara ! J'adore ton style, ton profil est super ✨ »
2. amara : « Merci Amina ! Tes photos de voyage sont magnifiques 🌍 »
3. user : « On pourrait échanger sur Abidjan, j'y vais bientôt ! »

**premium ↔ kwame** (2 messages) :

1. premium : « Hey Kwame, fellow techie here! 👋 »
2. kwame : « Salut Kofi ! Content de te matcher. Tu bosses sur quoi ? »

---

## Outils dev

Disponibles uniquement si `ENVIRONMENT=development` ou `DEBUG_ENABLED=true`.

### API debug (backend)

| Méthode | Route | Action |
|---------|-------|--------|
| GET | `/api/v1/debug/fixtures/status` | État du seed |
| POST | `/api/v1/debug/fixtures/seed` | Lance le seed |
| POST | `/api/v1/debug/fixtures/reset` | Supprime les users fixture |
| GET | `/api/v1/debug/fixtures/users` | Liste complète avec mots de passe |
| POST | `/api/v1/debug/auth/login-as` | Connexion sans mot de passe (`{ "email": "..." }`) |
| GET | `/api/v1/debug/info` | Infos environnement et services |

Exemple — liste complète des comptes :

```powershell
curl http://localhost:8000/api/v1/debug/fixtures/users
```

Exemple — connexion rapide :

```powershell
curl -X POST http://localhost:8000/api/v1/debug/auth/login-as `
  -H "Content-Type: application/json" `
  -d '{"email": "admin@afromia.com"}'
```

### DebugPanel (frontend)

Panneau flottant en mode dev (`NEXT_PUBLIC_DEBUG=true`) : seed, reset, login-as par clic sur chaque fixture.

Fichier : [`SAFIRI/apps/frontend/src/components/debug/DebugPanel.tsx`](../SAFIRI/apps/frontend/src/components/debug/DebugPanel.tsx)

---

## Connexion rapide par cas d'usage

| Besoin | Email | Mot de passe |
|--------|-------|--------------|
| Admin backoffice | `admin@afromia.com` | `AdminPassword123!` |
| Modération | `moderator@afromia.com` | `FixturePass123!` |
| Premium / abonnement | `premium@afromia.com` | `FixturePass123!` |
| User standard + match | `user@afromia.com` | `FixturePass123!` |
| Test suspension | `suspended@afromia.com` | `FixturePass123!` |
| Test archivage | `archived@afromia.com` | `FixturePass123!` |
| Discover / swipe | n'importe quel `*@afromia.com` | `FixturePass123!` |

Page de connexion : http://localhost:3000/login

---

## Notes de maintenance

- **Source de vérité** : [`data.py`](../SAFIRI/apps/backend/app/dev/fixtures/data.py) — mettre à jour ce fichier doc si vous ajoutez ou modifiez des fixtures.
- **Doublons dans `data.py`** : les entrées `suspended` et `archived` sont définies deux fois (26 entrées, 24 emails uniques). Conséquence : `make fixtures-status` peut afficher `seeded: false` même quand tous les comptes sont chargés (24 ≠ 26).
- **Sécurité** : mots de passe en clair exposés via l'API debug et le DebugPanel — réservé au dev local uniquement.
- **Tests unitaires** : les tests créent des users ad hoc (`test@afromia.com`, etc.) — non inclus dans le seed et non supprimés par `fixtures-reset`.
- **AFFINIORA** : pas de comptes utilisateur ; seed interne SQLite pour modèles/datasets uniquement.

---

## Documentation complémentaire

- [Guide développeur local](./README.md)
- [Architecture SAFIRI](../SAFIRI/docs/ARCHITECTURE.md)
- [Spécification fonctionnelle — AUTH-08 login-as dev](./SPECIFICATION_FONCTIONNELLE.md)
