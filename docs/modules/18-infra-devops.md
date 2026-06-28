# Module 18 — Infra & DevOps

**Statut** : 🚧 En cours  
**Spec** : NFR-01 à NFR-14

---

## Vision

Stack locale fiable (`make bootstrap` → `make dev`) : Postgres, Redis, MinIO, AFFINIORA Docker, migrations, seed, Celery, logs centralisés, CI tests.

## État réel

| Composant | État |
|-----------|------|
| `make bootstrap` / `make dev` | 🟡 |
| Docker Postgres, Redis, MinIO | ✅ |
| AFFINIORA Docker (:8001) | 🟡 (hors compose SAFIRI, build long) |
| Celery worker | ❌ (manuel, non lancé par défaut) |
| Migrations Alembic | ✅ |
| Seed fixtures | ✅ |
| Logs `logs/latest.log` | ✅ |
| SMTP / OAuth / Stripe / VAPID | ❌ (secrets vides) |
| CI pytest | 🟡 |

## Bloqueurs transverses

Voir [ETAT_AVANCEMENT.md](../ETAT_AVANCEMENT.md) § Bloqueurs B1–B4.

## Recette

- Prérequis environnement — voir [RECETTE.md](../RECETTE.md) § 5
- 37 tests backend + 18 AFFINIORA + 3 E2E smoke

## Actions prioritaires (P0)

1. `make dev` fiable avec AFFINIORA + health checks
2. Lancer Celery automatiquement ou via flag `dev.ps1`
3. Mode email dev (`email_dev_mode`) documenté et activé par défaut en local
4. Documenter tous les secrets requis par sprint (S6 config)
