#!/usr/bin/env pwsh
# Celery worker + beat - terminal separe (ne bloque pas make dev)
param(
    [ValidateSet("local", "docker")]
    [string]$Mode = "local",

    [switch]$Build
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ScriptsDir = Join-Path $Root "docs\scripts"
$SafiriRoot = Join-Path $Root "SAFIRI"
$BackendRoot = Join-Path $SafiriRoot "apps\backend"
$EnvFile = Join-Path $SafiriRoot ".env"

. (Join-Path $ScriptsDir "lib\logging.ps1")
Initialize-AfromiaLog -Root $Root -Session "celery"
Add-PythonScriptsToPath

function Apply-LocalCeleryEnv {
    if (-not (Test-Path $EnvFile)) {
        throw "Fichier .env absent - lancez d'abord : make env-local puis make dev"
    }
    $env:ENV_FILE = $EnvFile
    $env:CELERY_BROKER_URL = "redis://localhost:6379/1"
    $env:CELERY_RESULT_BACKEND = "redis://localhost:6379/2"
    $env:AFFINIORA_API_URL = "http://localhost:8001"
}

function Start-LocalCelery {
    $celeryApp = "app.workers.celery_app"
    $isWindows = ($env:OS -eq "Windows_NT") -or ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows)

    Push-Location $BackendRoot
    $beatProc = $null
    try {
        if ($isWindows) {
            # Windows : pas de --beat sur le worker ; pool solo (prefork indisponible)
            Write-AfromiaLog ">> Windows : celery worker (pool solo) + beat (processus separe)" -Level cmd
            $beatProc = Start-Process -FilePath "python" -ArgumentList @(
                "-m", "celery", "-A", $celeryApp, "beat", "--loglevel=info"
            ) -WorkingDirectory $BackendRoot -PassThru -NoNewWindow
            if (-not $beatProc) {
                throw "Impossible de demarrer celery beat"
            }
            Start-Sleep -Seconds 2
            Write-AfromiaLog "  celery beat demarre (PID $($beatProc.Id))" -Level ok

            python -m celery -A $celeryApp worker --loglevel=info -P solo
            if ($LASTEXITCODE -ne 0) {
                throw "Celery worker a echoue (code $LASTEXITCODE)"
            }
            return
        }

        Write-AfromiaLog ">> python -m celery worker --beat (broker redis://localhost:6379/1)" -Level cmd
        python -m celery -A $celeryApp worker --beat --loglevel=info
        if ($LASTEXITCODE -ne 0) {
            throw "Celery local a echoue (code $LASTEXITCODE)"
        }
    }
    finally {
        if ($beatProc -and -not $beatProc.HasExited) {
            Stop-Process -Id $beatProc.Id -Force -ErrorAction SilentlyContinue
        }
        Pop-Location
    }
}

Write-Host ""
Write-AfromiaLog "=== Celery ($Mode) - worker + beat ===" -Level cmd
Write-AfromiaLog "  Arreter : Ctrl+C" -Level info
Write-Host ""

if ($Mode -eq "local") {
    Apply-LocalCeleryEnv
    Write-AfromiaLog "  Prerequis : make dev deja lance (Postgres + Redis Docker)" -Level info
    Start-LocalCelery
    exit 0
}

# Mode Docker - sans --build par defaut (evite apt-get/gcc bloquant)
Push-Location $SafiriRoot
try {
    $composeArgs = @("compose", "up", "-d")
    if ($Build) {
        $composeArgs += "--build"
    }
    $composeArgs += @("celery-worker", "celery-beat")
    Write-AfromiaLog ">> docker compose up celery-worker celery-beat" -Level cmd
    docker @composeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose up celery a echoue (code $LASTEXITCODE)"
    }
    Write-AfromiaLog ">> docker compose logs -f celery-worker celery-beat" -Level cmd
    docker compose logs -f celery-worker celery-beat
}
finally {
    Pop-Location
}
