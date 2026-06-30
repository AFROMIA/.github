#Requires -Version 5.1
<#
.SYNOPSIS
    Affiche les instructions pour activer la branch protection sur SAFIRI et AFFINIORA.
.EXAMPLE
    .\setup-branch-protection.ps1 -Owner myorg -SafiriRepo safiri -AffinioraRepo affiniora
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,
    [string]$SafiriRepo = "safiri",
    [string]$AffinioraRepo = "affiniora"
)

$doc = Join-Path (Split-Path $PSScriptRoot -Parent) "GITHUB_BRANCH_PROTECTION.md"
Write-Host ""
Write-Host "=== Branch protection AFROMIA ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation: $doc" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Executez un premier pipeline CI sur main pour enregistrer les status checks." -ForegroundColor White
Write-Host "2. GitHub > Settings > Branches > Add rule sur 'main':" -ForegroundColor White
Write-Host "   - Require pull request (1 approbation)" -ForegroundColor Gray
Write-Host "   - Require status checks (quality-gate + jobs CI)" -ForegroundColor Gray
Write-Host "   - Do not allow bypassing" -ForegroundColor Gray
Write-Host ""
Write-Host "SAFIRI checks: backend-lint, backend-unit-coverage, backend-integration-coverage," -ForegroundColor Green
Write-Host "               frontend-lint, frontend-unit-coverage, e2e-critical-paths, quality-gate" -ForegroundColor Green
Write-Host ""
Write-Host "AFFINIORA checks: ai-engine-lint, ai-engine-unit-coverage," -ForegroundColor Green
Write-Host "                 ai-engine-integration-coverage, quality-gate" -ForegroundColor Green
Write-Host ""
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "gh CLI detecte — exemple SAFIRI:" -ForegroundColor Yellow
    Write-Host "  gh api repos/$Owner/$SafiriRepo/branches/main/protection -X PUT ..." -ForegroundColor Gray
} else {
    Write-Host "Installez gh CLI pour automatiser: https://cli.github.com/" -ForegroundColor Yellow
}
