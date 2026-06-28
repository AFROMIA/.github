@echo off

title AFROMIA — Affiniora (ai-engine)

cd /d "%~dp0"

echo.

echo  AFROMIA — Affiniora IA (terminal separe)

echo  Prerequis : make dev-infra deja lance (Postgres/Redis SAFIRI)

echo  URL       : http://localhost:8001/docs

echo  Logs      : logs\latest.log

echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docs\scripts\affiniora.ps1"

if errorlevel 1 (

    echo.

    echo  ERREUR — consultez logs\latest.log

    pause

)

