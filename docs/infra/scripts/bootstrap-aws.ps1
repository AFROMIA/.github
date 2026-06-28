#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap infrastructure AWS AFROMIA (S3 state + Terraform apply).
.EXAMPLE
    .\bootstrap-aws.ps1 -Profile afromia-dev -Environment staging
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1",
    [string]$Environment = "staging",
    [string]$AlertEmail = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$TerraformDir = Join-Path (Split-Path $PSScriptRoot -Parent) "terraform\aws"
$StateBucket = "afromia-terraform-state"

Write-Host "`n=== AFROMIA — Bootstrap AWS ($Environment) ===" -ForegroundColor Cyan

# 1. Verifier l'identite
Write-Host "`n[1/5] Verification identite AWS..." -ForegroundColor Yellow
$account = aws sts get-caller-identity --profile $Profile --output json | ConvertFrom-Json
Write-Host "  Compte : $($account.Account) | ARN : $($account.Arn)" -ForegroundColor Green

# 2. Creer le bucket S3 pour l'etat Terraform
Write-Host "`n[2/5] Bucket S3 pour etat Terraform..." -ForegroundColor Yellow
$bucketExists = aws s3api head-bucket --bucket $StateBucket --profile $Profile 2>$null
if ($LASTEXITCODE -ne 0) {
    if ($Region -eq "us-east-1") {
        aws s3api create-bucket --bucket $StateBucket --profile $Profile --region $Region
    } else {
        aws s3api create-bucket --bucket $StateBucket --profile $Profile --region $Region `
            --create-bucket-configuration LocationConstraint=$Region
    }
    aws s3api put-bucket-versioning --bucket $StateBucket --profile $Profile `
        --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption --bucket $StateBucket --profile $Profile `
        --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
    Write-Host "  Bucket '$StateBucket' cree." -ForegroundColor Green
} else {
    Write-Host "  Bucket '$StateBucket' existe deja." -ForegroundColor Green
}

# 3. Generer mot de passe RDS si absent
Write-Host "`n[3/5] Mot de passe RDS..." -ForegroundColor Yellow
$tfvarsPath = Join-Path $TerraformDir "terraform.tfvars"
if (-not (Test-Path $tfvarsPath)) {
    $dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
    @"
aws_region   = "$Region"
environment  = "$Environment"
project_name = "afromia"
db_password  = "$dbPassword"
alert_email  = "$AlertEmail"
"@ | Set-Content $tfvarsPath -Encoding UTF8
    Write-Host "  terraform.tfvars cree (db_password genere)." -ForegroundColor Green
    Write-Host "  IMPORTANT : sauvegardez ce fichier, il contient le mot de passe RDS." -ForegroundColor Red
} else {
    Write-Host "  terraform.tfvars existe deja." -ForegroundColor Green
}

# 4. Terraform init + apply
Write-Host "`n[4/5] Terraform init + apply (~15-20 min)..." -ForegroundColor Yellow
Push-Location $TerraformDir
try {
    terraform init -input=false
    if ($LASTEXITCODE -ne 0) { throw "terraform init a echoue" }

    terraform plan -out=tfplan
    if ($LASTEXITCODE -ne 0) { throw "terraform plan a echoue" }

    Write-Host "`n  Application de l'infrastructure..." -ForegroundColor Yellow
    terraform apply -auto-approve tfplan
    if ($LASTEXITCODE -ne 0) { throw "terraform apply a echoue" }
} finally {
    Pop-Location
}

# 5. Afficher les outputs
Write-Host "`n[5/5] Outputs infrastructure :" -ForegroundColor Yellow
Push-Location $TerraformDir
terraform output
Pop-Location

Write-Host "`n=== Bootstrap termine ===" -ForegroundColor Green
Write-Host "Prochaine etape : .\deploy-staging.ps1 -Profile $Profile" -ForegroundColor Cyan
Write-Host "Documentation : docs\infra\AWS_DEPLOYMENT.md" -ForegroundColor Cyan
