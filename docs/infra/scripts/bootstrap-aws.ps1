#Requires -Version 5.1
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1",
    [string]$Environment = "staging",
    [string]$AlertEmail = ""
)

$ErrorActionPreference = "Stop"
$TerraformDir = Join-Path (Split-Path $PSScriptRoot -Parent) "terraform\aws"
$StateBucket = "afromia-577239834825-terraform-state"

Write-Host ""
Write-Host "=== AFROMIA Bootstrap AWS ($Environment) ===" -ForegroundColor Cyan

Write-Host ""
Write-Host "[1/5] AWS identity..." -ForegroundColor Yellow
$account = aws sts get-caller-identity --profile $Profile --output json | ConvertFrom-Json
Write-Host "  Account: $($account.Account)" -ForegroundColor Green

Write-Host ""
Write-Host "[2/5] S3 state bucket..." -ForegroundColor Yellow
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
aws s3api head-bucket --bucket $StateBucket --profile $Profile 2>&1 | Out-Null
$bucketExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prevEap
if (-not $bucketExists) {
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
    Write-Host "  Bucket created: $StateBucket" -ForegroundColor Green
} else {
    Write-Host "  Bucket exists: $StateBucket" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3/5] terraform.tfvars..." -ForegroundColor Yellow
$tfvarsPath = Join-Path $TerraformDir "terraform.tfvars"
if (-not (Test-Path $tfvarsPath)) {
    $dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
    $lines = @(
        "aws_region         = `"$Region`""
        "environment        = `"$Environment`""
        "project_name       = `"afromia`""
        "db_password        = `"$dbPassword`""
        "alert_email        = `"$AlertEmail`""
        "enable_nat_gateway = false"
    )
    Set-Content -Path $tfvarsPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
    Write-Host "  terraform.tfvars created" -ForegroundColor Green
} else {
    Write-Host "  terraform.tfvars already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "[4/5] terraform init + apply (~15-20 min)..." -ForegroundColor Yellow
Push-Location $TerraformDir
try {
    terraform init -input=false
    if ($LASTEXITCODE -ne 0) { throw "terraform init failed" }
    terraform plan -out=tfplan
    if ($LASTEXITCODE -ne 0) { throw "terraform plan failed" }
    Write-Host "  Applying infrastructure..." -ForegroundColor Yellow
    terraform apply -auto-approve tfplan
    if ($LASTEXITCODE -ne 0) { throw "terraform apply failed" }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "[5/5] Outputs:" -ForegroundColor Yellow
Push-Location $TerraformDir
terraform output
Pop-Location

Write-Host ""
Write-Host "=== Bootstrap complete ===" -ForegroundColor Green
Write-Host "Next: deploy-staging.ps1 -Profile $Profile" -ForegroundColor Cyan
