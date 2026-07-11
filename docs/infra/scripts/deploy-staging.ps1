#Requires -Version 5.1
<#
.SYNOPSIS
    Build, push ECR et deploie les services ECS staging.
.EXAMPLE
    .\deploy-staging.ps1 -Profile afromia-dev
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1",
    [string]$Environment = "staging",
    [string]$Tag = "staging",
    [string]$CloudFrontDomain = ""
)

$ErrorActionPreference = "Stop"
$AfromiaRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
$SafiriRoot = Join-Path $AfromiaRoot "SAFIRI"
$AffinioraRoot = Join-Path $AfromiaRoot "AFFINIORA"
$Cluster = "afromia-$Environment"

Write-Host "`n=== AFROMIA - Deploiement $Environment ===" -ForegroundColor Cyan

# Login ECR
Write-Host "`n[1/4] Login ECR..." -ForegroundColor Yellow
$accountId = (aws sts get-caller-identity --profile $Profile --query Account --output text)
$ecrRegistry = "$accountId.dkr.ecr.$Region.amazonaws.com"
$ecrPassword = aws ecr get-login-password --profile $Profile --region $Region
if ($LASTEXITCODE -ne 0) { throw "ECR get-login-password echoue" }
$ecrPassword | docker login --username AWS --password-stdin $ecrRegistry
if ($LASTEXITCODE -ne 0) { throw "ECR login echoue - Docker Desktop est-il demarre ?" }

# CloudFront domain (build-time NEXT_PUBLIC_* - pas les env ECS runtime)
if (-not $CloudFrontDomain) {
    $TerraformDir = Join-Path (Split-Path $PSScriptRoot -Parent) "terraform\aws"
    Push-Location $TerraformDir
    $CloudFrontDomain = (terraform output -raw cloudfront_domain 2>$null)
    Pop-Location
}
if (-not $CloudFrontDomain) {
    throw "CloudFrontDomain requis : -CloudFrontDomain d38z5uj3ynysqy.cloudfront.net ou terraform output cloudfront_domain"
}
$publicApiUrl = "https://$CloudFrontDomain"
$publicWsUrl = "wss://$CloudFrontDomain"
Write-Host "  NEXT_PUBLIC_API_URL=$publicApiUrl (sans /api - le client ajoute /api/v1)" -ForegroundColor DarkGray

# Build + push SAFIRI
Write-Host "`n[2/4] Build SAFIRI (backend + frontend)..." -ForegroundColor Yellow
Push-Location $SafiriRoot
docker build -f infra/docker/Dockerfile.backend -t "${ecrRegistry}/safiri-backend:${Tag}" .
docker push "${ecrRegistry}/safiri-backend:${Tag}"
docker build -f infra/docker/Dockerfile.frontend.prod `
  --build-arg NEXT_PUBLIC_API_URL="$publicApiUrl" `
  --build-arg NEXT_PUBLIC_WS_URL="$publicWsUrl" `
  --build-arg NEXT_PUBLIC_DEBUG=true `
  -t "${ecrRegistry}/safiri-frontend:${Tag}" .
docker push "${ecrRegistry}/safiri-frontend:${Tag}"
Pop-Location

# Build + push AFFINIORA
Write-Host "`n[3/4] Build AFFINIORA (ai-engine, ~10 min)..." -ForegroundColor Yellow
Push-Location $AffinioraRoot
docker build -f infra/docker/Dockerfile -t "${ecrRegistry}/affiniora-ai-engine:${Tag}" .
docker push "${ecrRegistry}/affiniora-ai-engine:${Tag}"
Pop-Location

# Deploy ECS
Write-Host "`n[4/4] Redeploiement ECS..." -ForegroundColor Yellow
$services = @("safiri-backend", "safiri-frontend", "safiri-celery-worker", "safiri-celery-beat", "affiniora-ai-engine")
foreach ($svc in $services) {
    Write-Host "  -> $svc"
    aws ecs update-service --cluster $Cluster --service $svc --force-new-deployment --profile $Profile --region $Region 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    (service $svc pas encore cree - sera disponible apres terraform apply complet)" -ForegroundColor DarkYellow
    }
}

Write-Host "`n=== Deploiement lance ===" -ForegroundColor Green
Write-Host "Suivre le statut : aws ecs describe-services --cluster $Cluster --services safiri-backend --profile $Profile" -ForegroundColor Cyan
