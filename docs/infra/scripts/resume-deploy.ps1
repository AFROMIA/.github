#Requires -Version 5.1
<#
.SYNOPSIS
    Reprend le deploiement apres correction des permissions IAM.
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1"
)

$ErrorActionPreference = "Stop"
$TerraformDir = Join-Path (Split-Path $PSScriptRoot -Parent) "terraform\aws"
$env:AWS_PROFILE = $Profile

Write-Host "Verification permissions..." -ForegroundColor Yellow
aws sts get-caller-identity --profile $Profile | Out-Null

Write-Host "Terraform apply..." -ForegroundColor Yellow
Push-Location $TerraformDir
terraform apply -auto-approve tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "Plan obsolete, regeneration..." -ForegroundColor Yellow
    terraform plan -out=tfplan
    terraform apply -auto-approve tfplan
}
terraform output | Tee-Object -FilePath "..\..\..\logs\terraform-outputs.txt"
Pop-Location

Write-Host "Secrets Manager..." -ForegroundColor Yellow
& "$PSScriptRoot\setup-secrets.ps1" -Profile $Profile

Write-Host "Deploy images ECR + ECS..." -ForegroundColor Yellow
& "$PSScriptRoot\deploy-staging.ps1" -Profile $Profile -Region $Region

Write-Host "Attente stabilisation ECS (2 min)..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

Write-Host "Migrations DB..." -ForegroundColor Yellow
& "$PSScriptRoot\run-migrations.ps1" -Profile $Profile -Region $Region

Write-Host ""
Write-Host "=== Deploiement termine ===" -ForegroundColor Green
Push-Location $TerraformDir
$cf = terraform output -raw cloudfront_domain 2>$null
Pop-Location
if ($cf) { Write-Host "URL: https://$cf" -ForegroundColor Cyan }
