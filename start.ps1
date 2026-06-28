#!/usr/bin/env pwsh
# Raccourci racine -> docs/start.ps1
param(
    [ValidateSet("local", "docker", "supabase", "bootstrap")]
    [string]$Mode = "local",
    [switch]$SkipBootstrap
)

$Root = $PSScriptRoot
$startScript = Join-Path $Root "docs\start.ps1"

if ($SkipBootstrap) {
    & $startScript -Mode $Mode -SkipBootstrap
} else {
    & $startScript -Mode $Mode
}
