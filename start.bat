@echo off
title AFROMIA — Demarrage
cd /d "%~dp0"
echo.
echo  AFROMIA — Lancement en cours...
echo  Logs centralises : logs\latest.log
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docs\start.ps1" -Mode local
if errorlevel 1 (
    echo.
    echo  ERREUR — consultez logs\latest.log
    pause
)
