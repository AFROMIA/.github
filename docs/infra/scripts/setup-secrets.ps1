#Requires -Version 5.1
<#
.SYNOPSIS
    Genere et stocke les secrets applicatifs dans AWS Secrets Manager.
.EXAMPLE
    .\setup-secrets.ps1 -Profile afromia-dev -Environment staging
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1",
    [string]$Environment = "staging"
)

$ErrorActionPreference = "Stop"
$SecretName = "afromia-$Environment/app-secrets"

function New-RandomHex([int]$Bytes = 32) {
    $buf = New-Object byte[] $Bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($buf)
    return [BitConverter]::ToString($buf).Replace("-", "").ToLower()
}

$jwt = New-RandomHex 32
$secret = New-RandomHex 32

$payload = @{
    JWT_SECRET_KEY = $jwt
    SECRET_KEY     = $secret
} | ConvertTo-Json -Compress

Write-Host "Mise a jour secret $SecretName..." -ForegroundColor Yellow
aws secretsmanager put-secret-value `
    --secret-id $SecretName `
    --secret-string $payload `
    --profile $Profile `
    --region $Region 2>$null

if ($LASTEXITCODE -ne 0) {
    aws secretsmanager create-secret `
        --name $SecretName `
        --secret-string $payload `
        --profile $Profile `
        --region $Region
}

Write-Host "Secrets JWT/SECRET_KEY configures." -ForegroundColor Green
