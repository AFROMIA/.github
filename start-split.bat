@echo off
title AFROMIA — Demarrage grille dev
cd /d "%~dp0"
echo.
echo  AFROMIA — Infra dans ce terminal, puis grille 2x2 Windows Terminal
echo  Backend ^| Frontend ^| Affiniora ^| Celery
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docs\scripts\start-split.ps1" %*
if errorlevel 1 (
    echo.
    echo  ERREUR — consultez logs\latest.log
    pause
) else (
    echo.
    echo  Infra OK — grille dev ouverte. Vous pouvez fermer ce terminal.
    timeout /t 4 /nobreak >nul
)
