#!/usr/bin/env pwsh
# Bootstrap AFROMIA - installations verbeuses, logs centralises
param(
    [switch]$SkipPython,
    [switch]$SkipNpm,
    [switch]$SkipPreCommit,
    # AFFINIORA tourne en Docker par defaut - pip local (torch/scipy ~2 Go) optionnel
    [switch]$IncludeAffinioraPython
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
$ScriptsDir = Join-Path $Root "docs\scripts"
$SafiriRoot = Join-Path $Root "SAFIRI"
$AffinioraRoot = Join-Path $Root "AFFINIORA"

. (Join-Path $ScriptsDir "lib\logging.ps1")
Initialize-AfromiaLog -Root $Root -Session "bootstrap"
Add-PythonScriptsToPath

$totalSteps = 5
if ($SkipNpm) { $totalSteps-- }
if ($SkipPython) { $totalSteps-- }
if ($IncludeAffinioraPython -and -not $SkipPython) { $totalSteps++ }
if (-not $SkipPreCommit) { $totalSteps++ }

$step = 0

# 1. Fichiers .env
$step++
Start-AfromiaStep -Title "Configuration des fichiers .env" -Step $step -Total $totalSteps

$envTemplate = Join-Path $Root "docs\env-profiles\local.env.example"
if (-not (Test-Path $envTemplate)) {
    $envTemplate = Join-Path $SafiriRoot ".env.example"
}

$targets = @(
    (Join-Path $SafiriRoot ".env"),
    (Join-Path $AffinioraRoot ".env")
)

foreach ($target in $targets) {
    if (-not (Test-Path $target)) {
        if ($target -like "*AFFINIORA*" -and (Test-Path (Join-Path $AffinioraRoot ".env.example"))) {
            Copy-Item (Join-Path $AffinioraRoot ".env.example") $target -Force
        } elseif (Test-Path $envTemplate) {
            Copy-Item $envTemplate $target -Force
        }
        Write-AfromiaLog "  Cree : $target"
    } else {
        Write-AfromiaLog "  Existe deja : $target"
    }
}
Complete-AfromiaStep "Configuration .env" ([TimeSpan]::FromSeconds(0))

# 2. npm SAFIRI (verbose)
if (-not $SkipNpm) {
    $step++
    Start-AfromiaStep -Title "npm install SAFIRI (workspaces frontend + packages)" -Step $step -Total $totalSteps

    $npmEnv = @{
        NPM_CONFIG_LOGLEVEL = "verbose"
        NPM_CONFIG_PROGRESS = "true"
    }

    Invoke-AfromiaCommand `
        -Label "npm install SAFIRI" `
        -Command "npm" `
        -Arguments @("install", "--loglevel", "verbose", "--no-audit", "--no-fund") `
        -WorkingDirectory $SafiriRoot `
        -Environment $npmEnv
}

# 3. pip backend SAFIRI
if (-not $SkipPython) {
    $step++
    Start-AfromiaStep -Title "pip install SAFIRI backend" -Step $step -Total $totalSteps

    Invoke-PipInstall `
        -Label "pip install backend" `
        -WorkingDirectory (Join-Path $SafiriRoot "apps\backend")
}

# 4. pip AFFINIORA (optionnel - Docker suffit pour make dev)
if ($IncludeAffinioraPython -and (-not $SkipPython)) {
    $step++
    Start-AfromiaStep -Title "pip install AFFINIORA ai-engine (optionnel, ~2 Go)" -Step $step -Total $totalSteps

    try {
        Invoke-PipInstall `
            -Label "pip install ai-engine" `
            -WorkingDirectory (Join-Path $AffinioraRoot "services\ai-engine")
    } catch {
        Write-AfromiaLog "  AFFINIORA pip echoue - non bloquant (Docker fournit ai-engine)" -Level warn
        Complete-AfromiaStep "pip AFFINIORA (ignore)" ([TimeSpan]::FromSeconds(0))
    }
} else {
    Write-AfromiaLog "  AFFINIORA pip ignore - ai-engine demarre via Docker (make dev)" -Level info
}

# 5. Verification des prerequis
$step++
Start-AfromiaStep -Title "Verification des prerequis" -Step $step -Total $totalSteps

$checks = @(
    @{ Name = "Node.js"; Cmd = "node"; Args = @("--version") },
    @{ Name = "npm"; Cmd = "npm"; Args = @("--version") },
    @{ Name = "Python"; Cmd = "python"; Args = @("--version") },
    @{ Name = "Docker"; Cmd = "docker"; Args = @("--version") }
)

foreach ($check in $checks) {
    try {
        $cmdName = $check.Cmd
        $cmdArgs = $check.Args
        $ver = & $cmdName @cmdArgs 2>&1 | Select-Object -First 1
        Write-AfromiaLog "  OK $($check.Name) : $ver" -Level ok
    } catch {
        Write-AfromiaLog "  -- $($check.Name) : non trouve" -Level warn
    }
}
Complete-AfromiaStep "Verification prerequis" ([TimeSpan]::FromSeconds(0))

# 6. pre-commit
if (-not $SkipPreCommit) {
    $step++
    Start-AfromiaStep -Title "pre-commit hooks" -Step $step -Total $totalSteps

    $preCommitConfig = Join-Path $SafiriRoot ".pre-commit-config.yaml"

    if ((Get-Command pre-commit -ErrorAction SilentlyContinue) -and (Test-Path $preCommitConfig)) {
        Invoke-AfromiaCommand `
            -Label "pre-commit install" `
            -Command "pre-commit" `
            -Arguments @("install") `
            -WorkingDirectory $SafiriRoot
    } else {
        Write-AfromiaLog "  pre-commit ignore (non installe ou config absente dans SAFIRI)" -Level warn
        Complete-AfromiaStep "pre-commit" ([TimeSpan]::FromSeconds(0))
    }
}

Write-Host ""
Write-AfromiaLog "===========================================================" -Level ok
Write-AfromiaLog "Bootstrap termine. Logs : $script:AfromiaLogLatest" -Level ok
Write-AfromiaLog "Lancer l'app : start.bat  ou  make dev" -Level ok
if (-not $IncludeAffinioraPython) {
    Write-AfromiaLog "AFFINIORA ML local : make bootstrap-affiniora (optionnel)" -Level info
}
Write-AfromiaLog "===========================================================" -Level ok
