#!/usr/bin/env pwsh
# Configure les fichiers .env pour un profil AFROMIA (docker | local | supabase)
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("docker", "local", "supabase")]
    [string]$Profile
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
$Template = Join-Path $Root "docs\env-profiles\$Profile.env.example"

if (-not (Test-Path $Template)) {
    Write-Error "Template introuvable: $Template"
}

$SafiriEnv = Join-Path $Root "SAFIRI\.env"
$AffinioraEnv = Join-Path $Root "AFFINIORA\.env"

Copy-Item $Template $SafiriEnv -Force

# AFFINIORA : sous-ensemble minimal
$content = @"
# Généré par setup-env.ps1 ($Profile)
ENVIRONMENT=development
MODEL_CACHE_DIR=./models/cache
REDIS_URL=redis://localhost:6380/3
"@
if ($Profile -eq "docker") {
    $content = @"
ENVIRONMENT=development
MODEL_CACHE_DIR=/models/cache
REDIS_URL=redis://redis:6379/3
"@
}
Set-Content -Path $AffinioraEnv -Value $content -Encoding UTF8

Write-Host ""
Write-Host "Profil '$Profile' appliqué :" -ForegroundColor Green
Write-Host "  $SafiriEnv"
Write-Host "  $AffinioraEnv"

if ($Profile -eq "supabase") {
    $safiriContent = Get-Content $SafiriEnv -Raw
    if ($safiriContent -match '\[PROJECT_REF\]|\[PASSWORD\]|\[REGION\]') {
        Write-Host ""
        Write-Host "ATTENTION: éditez SAFIRI\.env avec vos identifiants Supabase" -ForegroundColor Yellow
        Write-Host "  Dashboard > Project Settings > Database > Connection string"
        Write-Host "  Extensions requises : postgis, vector"
    }
}

Write-Host ""
Write-Host "Prochaine étape : docs\scripts\dev.ps1 $Profile" -ForegroundColor Cyan
