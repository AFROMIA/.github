#!/usr/bin/env pwsh
# AFROMIA - Lancement en un clic (logs centralises dans logs/latest.log)
param(
    [ValidateSet("local", "docker", "supabase", "bootstrap")]
    [string]$Mode = "local",

    [switch]$SkipBootstrap,
    [switch]$WithCelery,
    [switch]$InfraOnly,
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
    [switch]$AffinioraOnly
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$ScriptsDir = Join-Path $Root "docs\scripts"

Write-Host ""
Write-Host "  =======================================" -ForegroundColor Yellow
Write-Host "       AFROMIA - Demarrage local" -ForegroundColor Yellow
Write-Host "  =======================================" -ForegroundColor Yellow
Write-Host ""

if ($Mode -eq "bootstrap") {
    & (Join-Path $ScriptsDir "bootstrap.ps1")
    exit $LASTEXITCODE
}

$devScript = Join-Path $ScriptsDir "dev.ps1"
$devArgs = @{ Mode = $Mode }
if ($SkipBootstrap) { $devArgs.SkipBootstrap = $true }
if ($WithCelery) { $devArgs.WithCelery = $true }
if ($InfraOnly) { $devArgs.InfraOnly = $true }
if ($BackendOnly) { $devArgs.BackendOnly = $true }
if ($FrontendOnly) { $devArgs.FrontendOnly = $true }
if ($AffinioraOnly) { $devArgs.AffinioraOnly = $true }
& $devScript @devArgs
