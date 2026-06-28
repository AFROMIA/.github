@echo off
title AFROMIA — Celery (worker + beat)
cd /d "%~dp0"
echo.
echo  AFROMIA — Celery (terminal separe)
echo  Prerequis : make dev deja lance dans un autre terminal
echo  Logs      : logs\latest.log
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docs\scripts\celery.ps1" -Mode local
if errorlevel 1 (
    echo.
    echo  ERREUR — consultez logs\latest.log
    pause
)
