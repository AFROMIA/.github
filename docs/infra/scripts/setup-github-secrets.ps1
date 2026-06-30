#Requires -Version 5.1
<#
.SYNOPSIS
    Configure GitHub Actions secrets for SAFIRI and AFFINIORA repos.
.EXAMPLE
    .\setup-github-secrets.ps1 -SafiriRepo "org/safiri" -AffinioraRepo "org/affiniora"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$SafiriRepo,
    [Parameter(Mandatory = $true)]
    [string]$AffinioraRepo,
    [string]$KeysFile = "..\..\..\afromia-dev-agent_accessKeys.csv"
)

$ErrorActionPreference = "Stop"
$keysPath = Join-Path $PSScriptRoot $KeysFile
if (-not (Test-Path $keysPath)) {
    throw "Fichier cles introuvable: $keysPath"
}

$keys = Import-Csv $keysPath
$accessKey = $keys.'Access key ID'
$secretKey = $keys.'Secret access key'

foreach ($repo in @($SafiriRepo, $AffinioraRepo)) {
    Write-Host "Secrets GitHub pour $repo..." -ForegroundColor Yellow
    gh secret set AWS_ACCESS_KEY_ID --body $accessKey --repo $repo
    gh secret set AWS_SECRET_ACCESS_KEY --body $secretKey --repo $repo
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Secrets configures. Les workflows deploy-staging.yml deployeront sur push main." -ForegroundColor Cyan
