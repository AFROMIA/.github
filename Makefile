.PHONY: help bootstrap install dev dev-local dev-infra dev-backend dev-frontend dev-affiniora dev-with-celery dev-docker dev-supabase dev-clean celery celery-docker celery-docker-build env-local env-docker env-supabase migrate seed fixtures-reset fixtures-status down clean

help:
	@echo AFROMIA — commandes (racine)
	@echo.
	@echo   make bootstrap       Installe les dependances (logs verbeux : logs/latest.log)
	@echo   make install         Bootstrap sans pre-commit
	@echo   make dev             Lance l'app (mode local, sans Celery)
	@echo   make dev-split       Multi-terminaux (infra + backend + frontend + affiniora + celery)
	@echo   make dev-infra       Infra Docker + migrations (terminal 1)
	@echo   make dev-backend     Backend seul (terminal 2, apres dev-infra)
	@echo   make dev-frontend    Frontend seul (terminal 3, apres dev-infra)
	@echo   make dev-affiniora   Affiniora IA Docker (terminal 4, optionnel)
	@echo   make dev-affiniora-build Rebuild image Affiniora (1ere fois ou apres changement Dockerfile)
	@echo   make dev-with-celery Lance l'app + Celery Docker (peut etre lent)
	@echo   make celery          Celery local — autre terminal (recommande)
	@echo   make celery-docker   Celery via Docker — autre terminal
	@echo   make dev-docker      Lance tout dans Docker
	@echo   make dev-clean       Purge cache Next.js (si 500 / hot reload casse)
	@echo   make env-local       Configure SAFIRI/.env (profil local)
	@echo   make migrate         Migrations Alembic
	@echo   make seed            Fixtures manuelles (Debug Panel recommande)
	@echo   start.bat            Lancement en un clic (Windows, 1 terminal)
	@echo   start-split.bat      4 terminaux separes (recommande dev actif)
	@echo   start-celery.bat     Celery en un clic (2e terminal Windows)
	@echo   start-affiniora.bat  Affiniora IA en un clic (terminal separe)

bootstrap:
	powershell -ExecutionPolicy Bypass -File docs/scripts/bootstrap.ps1

bootstrap-affiniora:
	powershell -ExecutionPolicy Bypass -File docs/scripts/bootstrap.ps1 -IncludeAffinioraPython -SkipNpm -SkipPreCommit

install:
	powershell -ExecutionPolicy Bypass -File docs/scripts/bootstrap.ps1 -SkipPreCommit

dev: dev-local

AFROMIA_ROOT := $(CURDIR)
DEV_SPLIT_PS1 := $(AFROMIA_ROOT)/docs/scripts/start-split.ps1

SPLIT_ARGS :=
ifdef SKIP_INFRA
SPLIT_ARGS += -SkipInfra
endif

dev-split:
	powershell -NoProfile -ExecutionPolicy Bypass -File "$(DEV_SPLIT_PS1)" $(SPLIT_ARGS)

dev-infra:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode local -InfraOnly

dev-backend:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode local -BackendOnly

dev-frontend:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode local -FrontendOnly

dev-affiniora:
	powershell -ExecutionPolicy Bypass -File docs/scripts/affiniora.ps1

dev-affiniora-build:
	powershell -ExecutionPolicy Bypass -File docs/scripts/affiniora.ps1 -Build

dev-clean:
	cd SAFIRI && npm run dev:clean

dev-local:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode local

dev-with-celery:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode local -WithCelery

celery:
	powershell -ExecutionPolicy Bypass -File docs/scripts/celery.ps1 -Mode local

celery-docker:
	powershell -ExecutionPolicy Bypass -File docs/scripts/celery.ps1 -Mode docker

celery-docker-build:
	powershell -ExecutionPolicy Bypass -File docs/scripts/celery.ps1 -Mode docker -Build

dev-docker:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode docker

dev-supabase:
	powershell -ExecutionPolicy Bypass -File docs/start.ps1 -Mode supabase

env-local:
	powershell -ExecutionPolicy Bypass -File docs/scripts/setup-env.ps1 local

env-docker:
	powershell -ExecutionPolicy Bypass -File docs/scripts/setup-env.ps1 docker

env-supabase:
	powershell -ExecutionPolicy Bypass -File docs/scripts/setup-env.ps1 supabase

migrate:
	set ENV_FILE=SAFIRI\.env&& cd SAFIRI/apps/backend && alembic upgrade head

seed:
	set ENV_FILE=SAFIRI\.env&& cd SAFIRI/apps/backend && python scripts/seed_data.py

fixtures-reset:
	set ENV_FILE=SAFIRI\.env&& cd SAFIRI/apps/backend && python scripts/seed_data.py reset

fixtures-status:
	set ENV_FILE=SAFIRI\.env&& cd SAFIRI/apps/backend && python scripts/seed_data.py status

down:
	cd SAFIRI && docker compose down
	cd AFFINIORA && docker compose down

clean:
	cd SAFIRI && docker compose down -v --remove-orphans
	cd AFFINIORA && docker compose down -v --remove-orphans
