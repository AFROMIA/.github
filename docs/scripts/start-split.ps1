#!/usr/bin/env pwsh
# Lance infra (fenetre qui se ferme) puis 4 services : grille WT si dispo, sinon fenetres separees
param(
    [switch]$SkipInfra,
    [switch]$SkipCelery,
    [switch]$Grid,
    [switch]$SeparateWindows,
    [int]$InfraWaitSeconds = 90
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

function Resolve-WtExe {
    $cmd = Get-Command wt.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    foreach ($candidate in @(
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe",
            "$env:ProgramFiles\Windows Terminal\wt.exe",
            "${env:ProgramFiles(x86)}\Windows Terminal\wt.exe"
        )) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return $candidate
        }
    }
    return $null
}

function New-PaneScript {
    param(
        [string]$Title,
        [string]$MakeTarget,
        [switch]$AutoClose
    )

    $escapedRoot = $Root.Replace("'", "''")
    $exitBlock = if ($AutoClose) {
        @"

Write-Host ''
Write-Host '  Termine - fermeture dans 3s...' -ForegroundColor Green
Start-Sleep -Seconds 3
exit `$LASTEXITCODE
"@
    } else { "" }

    return @"
Set-Location -LiteralPath '$escapedRoot'
`$Host.UI.RawUI.WindowTitle = '$Title'
Write-Host ''
Write-Host '  $Title' -ForegroundColor Cyan
Write-Host '  make $MakeTarget' -ForegroundColor DarkGray
Write-Host ''
make $MakeTarget
$exitBlock
"@
}

function Start-DevWindow {
    param(
        [string]$Title,
        [string]$MakeTarget,
        [int]$DelaySeconds = 0,
        [switch]$AutoClose
    )

    if ($DelaySeconds -gt 0) {
        Start-Sleep -Seconds $DelaySeconds
    }

    $script = New-PaneScript -Title $Title -MakeTarget $MakeTarget -AutoClose:$AutoClose
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass"
    )
    if (-not $AutoClose) {
        $args += "-NoExit"
    }
    $args += @("-Command", $script)

    Start-Process -FilePath "powershell.exe" -ArgumentList $args -WorkingDirectory $Root | Out-Null
}

function Start-WindowsTerminalGrid {
    param(
        [string]$WtExe,
        [bool]$IncludeCelery = $true
    )

    function PaneArgs([string]$Title, [string]$Target) {
        $script = New-PaneScript -Title $Title -MakeTarget $Target
        return @("powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $script)
    }

    $backend = PaneArgs "Backend :8000" "dev-backend"
    $frontend = PaneArgs "Frontend :3000" "dev-frontend"
    $affiniora = PaneArgs "Affiniora :8001" "dev-affiniora"
    $celery = PaneArgs "Celery worker" "celery"

    $wtArgs = @("-M", "-w", "-1", "nt", "--title", "Backend", "-d", $Root) + $backend

    if ($IncludeCelery) {
        $wtArgs += @(";") + @("sp", "-V", "-s", "0.5", "--title", "Frontend", "-d", $Root) + $frontend
        $wtArgs += @(";") + @("focus-pane", "-t", "0", ";", "sp", "-H", "-s", "0.5", "--title", "Affiniora", "-d", $Root) + $affiniora
        $wtArgs += @(";") + @("focus-pane", "-t", "1", ";", "sp", "-H", "-s", "0.5", "--title", "Celery", "-d", $Root) + $celery
    } else {
        $wtArgs += @(";") + @("sp", "-V", "-s", "0.5", "--title", "Frontend", "-d", $Root) + $frontend
        $wtArgs += @(";") + @("focus-pane", "-t", "0", ";", "sp", "-H", "-s", "0.5", "--title", "Affiniora", "-d", $Root) + $affiniora
    }

    Start-Process -FilePath $WtExe -ArgumentList $wtArgs -WorkingDirectory $Root | Out-Null
}

function Start-SeparateDevWindows {
    param([bool]$IncludeCelery = $true)

    Write-Host "  Ouverture fenetre Backend (apres attente infra)..." -ForegroundColor Cyan
    Start-DevWindow -Title "Backend :8000" -MakeTarget "dev-backend" -DelaySeconds 15

    Write-Host "  Ouverture fenetre Frontend..." -ForegroundColor Cyan
    Start-DevWindow -Title "Frontend :3000" -MakeTarget "dev-frontend" -DelaySeconds 1

    Write-Host "  Ouverture fenetre Affiniora..." -ForegroundColor Cyan
    Start-DevWindow -Title "Affiniora :8001" -MakeTarget "dev-affiniora" -DelaySeconds 1

    if ($IncludeCelery) {
        Write-Host "  Ouverture fenetre Celery..." -ForegroundColor Cyan
        Start-DevWindow -Title "Celery worker" -MakeTarget "celery" -DelaySeconds 1
    }
}

Write-Host ""
Write-Host "  AFROMIA - demarrage multi-terminaux" -ForegroundColor Yellow
Write-Host "  Racine : $Root" -ForegroundColor DarkGray
Write-Host ""

$includeCelery = -not $SkipCelery
$wtExe = Resolve-WtExe
$useGrid = ($Grid -or ($wtExe -and -not $SeparateWindows))

if (-not $SkipInfra) {
    Write-Host "  [1] Infra Docker + migrations (fenetre dediee, se ferme a la fin)..." -ForegroundColor Cyan
    Start-DevWindow -Title "Infra SAFIRI" -MakeTarget "dev-infra" -AutoClose
    Write-Host "  Attente ${InfraWaitSeconds}s que Postgres demarre..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $InfraWaitSeconds
} else {
    Write-Host "  [1] Infra ignoree (-SkipInfra)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  [2] Lancement des services dev..." -ForegroundColor Cyan

if ($useGrid -and $wtExe) {
    try {
        Start-WindowsTerminalGrid -WtExe $wtExe -IncludeCelery:$includeCelery
        Write-Host "  Grille 2x2 Windows Terminal ouverte" -ForegroundColor Green
    } catch {
        Write-Host "  Grille WT echouee : $($_.Exception.Message)" -ForegroundColor Yellow
        Start-SeparateDevWindows -IncludeCelery:$includeCelery
        Write-Host "  Fallback : 4 fenetres PowerShell separees" -ForegroundColor Yellow
    }
} else {
    if (-not $wtExe) {
        Write-Host "  Windows Terminal (wt) introuvable - fenetres separees" -ForegroundColor DarkGray
    }
    Start-SeparateDevWindows -IncludeCelery:$includeCelery
    Write-Host "  4 fenetres PowerShell ouvertes" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Frontend  : http://localhost:3000" -ForegroundColor Green
Write-Host "  Backend   : http://localhost:8000/docs" -ForegroundColor Green
Write-Host "  Affiniora : http://localhost:8001/docs" -ForegroundColor Green
if ($includeCelery) {
    Write-Host "  Celery    : worker + beat" -ForegroundColor Green
}
Write-Host ""
Write-Host "  Astuce : make dev-split depuis AFROMIA/, SAFIRI/ ou AFFINIORA/" -ForegroundColor DarkGray
Write-Host "  Infra deja up : make dev-split SKIP_INFRA=1  (ou -SkipInfra)" -ForegroundColor DarkGray
Write-Host ""
