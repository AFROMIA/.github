#Requires -Version 5.1
<#
.SYNOPSIS
    Instructions pour accorder les permissions necessaires au deploiement AWS.
    A executer depuis le compte ROOT dans la console IAM.
#>
Write-Host ""
Write-Host "=== PERMISSIONS IAM REQUISES ===" -ForegroundColor Red
Write-Host ""
Write-Host "L utilisateur afromia-dev-agent n a pas les droits suffisants." -ForegroundColor Yellow
Write-Host "Depuis la console ROOT (https://577239834825.signin.aws.amazon.com/console) :" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. IAM > Utilisateurs > afromia-dev-agent"
Write-Host "  2. Autorisations > Ajouter des autorisations"
Write-Host "  3. Attacher directement : AdministratorAccess"
Write-Host "  4. Creer le bucket S3 : afromia-577239834825-terraform-state (region eu-west-1)"
Write-Host ""
Write-Host "Puis relancer : .\bootstrap-aws.ps1 -Profile afromia-dev" -ForegroundColor Green
Write-Host ""
