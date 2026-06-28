#Requires -Version 5.1
<#
.SYNOPSIS
    Configure le profil AWS CLI avec les cles d'acces programmatiques.
.NOTES
    Le fichier afromia-dev-agent_credentials.csv ne contient que le mot de passe CONSOLE.
    Il faut creer des cles API : Console AWS > afromia-dev-agent > Credentials de securite > Cles d'acces.
.EXAMPLE
    .\setup-access-keys.ps1 -AccessKeyId AKIA... -SecretAccessKey ...
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$AccessKeyId,
    [Parameter(Mandatory = $true)]
    [string]$SecretAccessKey,
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1"
)

aws configure set aws_access_key_id $AccessKeyId --profile $Profile
aws configure set aws_secret_access_key $SecretAccessKey --profile $Profile
aws configure set region $Region --profile $Profile
aws configure set output json --profile $Profile

Write-Host "Verification..." -ForegroundColor Yellow
aws sts get-caller-identity --profile $Profile
