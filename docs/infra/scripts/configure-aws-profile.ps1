#Requires -Version 5.1
<#
.SYNOPSIS
    Configure le profil AWS CLI pour l'agent dev AFROMIA.
.EXAMPLE
    .\configure-aws-profile.ps1
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1"
)

Write-Host "`n=== Configuration AWS CLI — profil '$Profile' ===" -ForegroundColor Cyan
Write-Host "Region par defaut : $Region`n"

aws configure --profile $Profile set region $Region
aws configure --profile $Profile set output json

Write-Host "Saisissez vos identifiants IAM (utilisateur afromia-dev-agent) :`n"
aws configure --profile $Profile

Write-Host "`nVerification de l'identite..." -ForegroundColor Yellow
$identity = aws sts get-caller-identity --profile $Profile 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR : authentification echouee." -ForegroundColor Red
    Write-Host $identity
    exit 1
}

Write-Host "Connecte avec succes :" -ForegroundColor Green
Write-Host $identity
Write-Host "`nProfil '$Profile' pret. Utilisez : aws <commande> --profile $Profile" -ForegroundColor Cyan
