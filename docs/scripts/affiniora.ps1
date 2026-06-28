#!/usr/bin/env pwsh
# Affiniora ai-engine (Docker) - terminal separe, independant de make dev
param(
    [switch]$Build,
    [switch]$Detached,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ScriptsDir = Join-Path $Root "docs\scripts"
$AffinioraRoot = Join-Path $Root "AFFINIORA"
$EnvFile = Join-Path $AffinioraRoot ".env"
$ComposeBase = Join-Path $AffinioraRoot "docker-compose.yml"
$ComposeDev = Join-Path $AffinioraRoot "docker-compose.dev.yml"
$ImageName = "affiniora-ai-engine:dev"

. (Join-Path $ScriptsDir "lib\logging.ps1")
Initialize-AfromiaLog -Root $Root -Session "affiniora"

function Ensure-AffinioraEnv {
    if (-not (Test-Path $EnvFile)) {
        $example = Join-Path $AffinioraRoot ".env.example"
        if (Test-Path $example) {
            Copy-Item $example $EnvFile
            Write-AfromiaLog "  AFFINIORA/.env cree depuis .env.example" -Level ok
        } else {
            throw "AFFINIORA/.env absent - copiez .env.example ou lancez make bootstrap"
        }
    }
}

function Test-DockerEngine {
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $info = docker info --format "{{.ServerVersion}}" 2>&1
        if ($LASTEXITCODE -ne 0) {
            return @{ Ok = $false; Message = ($info | Out-String).Trim() }
        }
        return @{ Ok = $true; Version = ($info | Out-String).Trim() }
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Show-DockerEngineHelp {
    param([string]$Detail = "")

    Write-AfromiaLog "" -Level err
    Write-AfromiaLog "DOCKER DESKTOP indisponible ou instable." -Level err
    if ($Detail) {
        Write-AfromiaLog "  Detail : $Detail" -Level err
    }
    Write-AfromiaLog "Correctifs :" -Level err
    Write-AfromiaLog "  1) Ouvrir Docker Desktop et attendre 'Engine running'" -Level err
    Write-AfromiaLog "  2) Docker Desktop > Restart (ou redemarrer Windows)" -Level err
    Write-AfromiaLog "  3) Puis : make dev-affiniora-build" -Level err
    Write-AfromiaLog "  Voir docs/TROUBLESHOOTING.md" -Level err
}

function Test-AffinioraImageLocal {
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        docker image inspect $ImageName 2>&1 | Out-Null
        return $LASTEXITCODE -eq 0
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Test-AffinioraRunning {
    Push-Location $AffinioraRoot
    try {
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $out = docker compose -f $ComposeBase -f $ComposeDev ps --status running --services ai-engine 2>&1
        $ErrorActionPreference = $prevEap
        return ($out -match "ai-engine")
    }
    finally {
        Pop-Location
    }
}

function Get-AffinioraComposeArgs {
    return @("compose", "-f", $ComposeBase, "-f", $ComposeDev)
}

function Invoke-AffinioraBuild {
    Push-Location $AffinioraRoot
    try {
        Write-AfromiaLog "  Build image $ImageName (PyTorch CPU - peut prendre 5-15 min la 1ere fois)..." -Level warn
        $buildArgs = Get-AffinioraComposeArgs + @("build", "ai-engine")
        Invoke-AfromiaCommand `
            -Label "docker compose build ai-engine" `
            -Command "docker" `
            -Arguments $buildArgs
    }
    finally {
        Pop-Location
    }
}

Ensure-AffinioraEnv

$docker = Test-DockerEngine
if (-not $docker.Ok) {
    Show-DockerEngineHelp -Detail $docker.Message
    exit 1
}
Write-AfromiaLog "  Docker OK (serveur $($docker.Version))" -Level ok

$needBuild = $Build -or (-not $SkipBuild -and -not (Test-AffinioraImageLocal))
if ($needBuild) {
    Invoke-AffinioraBuild
}

Write-Host ""
Write-AfromiaLog "===========================================================" -Level ok
Write-AfromiaLog "  Affiniora : http://localhost:8001/docs" -Level ok
Write-AfromiaLog "  Redis     : localhost:6380 (interne conteneur :6379)" -Level ok
Write-AfromiaLog "  Hot reload: uvicorn --reload (profil docker-compose.dev.yml)" -Level ok
Write-AfromiaLog "  Logs      : $script:AfromiaLogLatest" -Level ok
Write-AfromiaLog "===========================================================" -Level ok
Write-Host ""

if (Test-AffinioraRunning) {
    Write-AfromiaLog "  ai-engine deja actif - reattachement aux logs uniquement" -Level warn
}

Push-Location $AffinioraRoot
try {
    $composeArgs = Get-AffinioraComposeArgs

    if ($Detached) {
        $upArgs = $composeArgs + @("up", "-d", "redis", "ai-engine")
        Invoke-AfromiaCommand `
            -Label "docker compose up -d affiniora" `
            -Command "docker" `
            -Arguments $upArgs
        Write-AfromiaLog "Affiniora demarre en arriere-plan - logs : docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f ai-engine" -Level ok
        return
    }

    Write-AfromiaLog '>> docker compose up redis ai-engine (reload actif, Ctrl+C arrete Affiniora seulement)' -Level cmd
    Show-AppLogLegend

    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $upArgs = $composeArgs + @("up", "redis", "ai-engine")

    docker @upArgs 2>&1 | ForEach-Object {
        $line = $_.ToString()
        if ($line -match '(?i)Internal Server Error|dockerDesktopLinuxEngine|unable to get image') {
            Write-AffinioraStreamLog -Line $line
            Write-AffinioraStreamLog -Line "HINT: redemarrez Docker Desktop puis make dev-affiniora-build"
        } elseif ($line -match '^\S+\s+\|\s+(.*)$') {
            Write-AffinioraStreamLog -Line $Matches[1]
        } else {
            Write-AffinioraStreamLog -Line $line
        }
    }

    if ($LASTEXITCODE -ne 0) {
        Show-DockerEngineHelp -Detail "docker compose up code $LASTEXITCODE"
        exit $LASTEXITCODE
    }

    $ErrorActionPreference = $prevEap
}
finally {
    Pop-Location
}
