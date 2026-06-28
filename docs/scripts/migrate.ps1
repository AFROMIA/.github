#!/usr/bin/env pwsh
# Applique les migrations Alembic (utilise SAFIRI/.env ou ENV_FILE)
param(
    [ValidateSet("local", "docker", "supabase")]
    [string]$Profile = "local"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
$ScriptsDir = Join-Path $Root "docs\scripts"
$EnvFile = Join-Path $Root "SAFIRI\.env"

if (-not (Test-Path $EnvFile)) {
    & (Join-Path $ScriptsDir "setup-env.ps1") $Profile
}

$env:ENV_FILE = $EnvFile
if ($Profile -eq "docker") {
    $env:DATABASE_URL = "postgresql+asyncpg://afromia:afromia@localhost:5432/afromia"
    $env:DATABASE_URL_SYNC = "postgresql+psycopg://afromia:afromia@localhost:5432/afromia"
    $env:DATABASE_SSL = "false"
}

Push-Location (Join-Path $Root "SAFIRI\apps\backend")
alembic upgrade head
Pop-Location
Write-Host "Migrations appliquées." -ForegroundColor Green
