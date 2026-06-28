# Module de logging centralise AFROMIA - console + fichier

$script:AfromiaLogFile = $null
$script:AfromiaLogLatest = $null
$script:AfromiaStep = 0
$script:AfromiaStepTotal = 0
$script:LogTailJobs = @()
$script:LogTailTimer = $null
$script:LogTailEvent = $null

# Couleur unique par application (console uniquement - fichier reste en texte brut)
$script:AppLogColors = [ordered]@{
    "afromia"       = "DarkGray"
    "backend"       = "Blue"
    "frontend"      = "Green"
    "affiniora"     = "DarkCyan"
    "ai-engine"     = "DarkCyan"
    "postgres"      = "Yellow"
    "redis"         = "Red"
    "minio"         = "Cyan"
    "livekit"       = "Magenta"
    "coturn"        = "DarkYellow"
    "docker"        = "DarkGray"
    "celery-worker" = "DarkMagenta"
    "celery-beat"   = "DarkBlue"
    "celery"        = "DarkMagenta"
}

function Get-AppLogColor {
    param([string]$App)

    $key = ($App -replace '-\d+$', '').ToLower()
    if ($script:AppLogColors.Contains($key)) {
        return $script:AppLogColors[$key]
    }

    foreach ($pattern in $script:AppLogColors.Keys) {
        if ($key -like "*$pattern*") {
            return $script:AppLogColors[$pattern]
        }
    }

    return "Gray"
}

function Strip-AnsiCodes {
    param([string]$Text)
    return ($Text -replace '\x1b\[[0-9;]*m', '')
}

function Get-AfromiaLogPaths {
    $file = $script:AfromiaLogFile
    $latest = $script:AfromiaLogLatest
    if (-not $file) { $file = $global:AfromiaLogFilePath }
    if (-not $latest) { $latest = $global:AfromiaLogLatestPath }
    return @{ File = $file; Latest = $latest }
}

function Sync-AfromiaLatestLog {
    param(
        [string]$Source,
        [string]$Dest
    )

    if (-not $Source -or -not $Dest -or -not (Test-Path -LiteralPath $Source)) { return }

    try {
        Copy-Item -LiteralPath $Source -Destination $Dest -Force -ErrorAction Stop
    } catch {
        # Non bloquant : plusieurs terminaux (make dev-split) partagent latest.log
    }
}

function Write-AffinioraStreamLog {
    param([string]$Line)

    if ([string]::IsNullOrWhiteSpace($Line)) { return }

    $ts = Get-Date -Format "HH:mm:ss"
    $plain = "[$ts] [AFFINIORA] $Line"

    $glyph = [char]0x25C8
    $robotTag = "$glyph AI $glyph"

    $color = "DarkCyan"
    if ($Line -match '(?i)error|exception|fail|critical|traceback') {
        $color = "Red"
    } elseif ($Line -match '(?i)score|personality|compat|inference|model|analyze|detect|embedding') {
        $color = "Magenta"
    } elseif ($Line -match '(?i)warn|warning') {
        $color = "Yellow"
    } elseif ($Line -match '(?i)uvicorn|started|healthy|application startup|listening') {
        $color = "Cyan"
    }

    $display = "[$ts] $robotTag  $Line"
    Write-Host $display -ForegroundColor $color

    $paths = Get-AfromiaLogPaths
    if ($paths.File) {
        Add-Content -Path $paths.File -Value $plain -Encoding UTF8
        Sync-AfromiaLatestLog -Source $paths.File -Dest $paths.Latest
    }
}

function Write-StreamLogToFile {
    param([string]$Line)

    $paths = Get-AfromiaLogPaths
    if ($paths.File) {
        Add-Content -Path $paths.File -Value $Line -Encoding UTF8
        Sync-AfromiaLatestLog -Source $paths.File -Dest $paths.Latest
    }
}

function Write-StreamLog {
    param([string]$Line)

    $plainLine = Strip-AnsiCodes $Line
    $color = $null
    $message = $plainLine

    if ($plainLine -match '^\[([^\]]+)\]\s*(.*)$') {
        $appKey = $Matches[1].ToLower()
        $message = $Matches[2]
        if ($appKey -match 'affiniora|ai-engine|ai') {
            Write-AffinioraStreamLog -Line $(if ($message) { $message } else { $plainLine })
            return
        }
        $color = Get-AppLogColor $appKey
        $plainLine = "[$($Matches[1])] $message"
    }
    elseif ($plainLine -match '^([\w.-]+)\s+\|\s*(.*)$') {
        $svc = ($Matches[1] -replace '-\d+$', '').ToLower()
        $message = $Matches[2]
        if ($svc -match 'affiniora|ai-engine|ai') {
            Write-AffinioraStreamLog -Line $message
            return
        }
        if ($svc -match 'livekit') {
            if ($message -match '(?i)error|fail|ice failed|disconnect') {
                $color = "Red"
            } elseif ($message -match '(?i)warn|warning') {
                $color = "Yellow"
            } else {
                $color = Get-AppLogColor "livekit"
            }
            $plainLine = "[$svc] $message"
            Write-Host $plainLine -ForegroundColor $color
            Write-StreamLogToFile -Line $plainLine
            return
        }
        if ($svc -match 'coturn') {
            if ($message -match '(?i)error|fail|denied') {
                $color = "Red"
            } elseif ($message -match '(?i)warn|warning|NO EXPLICIT') {
                $color = "Yellow"
            } else {
                $color = Get-AppLogColor "coturn"
            }
            $plainLine = "[$svc] $message"
            Write-Host $plainLine -ForegroundColor $color
            Write-StreamLogToFile -Line $plainLine
            return
        }
        $color = Get-AppLogColor $svc
    }

    if ($color) {
        Write-Host $plainLine -ForegroundColor $color
    } else {
        Write-Host $plainLine
    }

    Write-StreamLogToFile -Line $plainLine
}

function Start-CentralizedDockerLogs {
    param(
        [string]$SafiriDir,
        [string]$AffinioraDir,
        [switch]$SkipAffiniora
    )

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-AfromiaLog "  Docker absent - capture logs conteneurs ignoree" -Level warn
        return
    }

    Write-AfromiaLog "Capture logs Docker centralisee (fichier + console)..." -Level cmd
    Write-AfromiaLog "  Tip : police Cascadia Mono / Consolas pour le style robot Affiniora" -Level info

    if (Test-Path $SafiriDir) {
        $script:LogTailJobs += Start-Job -Name "safiri-docker" -ScriptBlock {
            param($Dir)
            Set-Location $Dir
            docker compose logs -f --tail=25 postgres redis minio livekit coturn celery-worker celery-beat 2>&1
        } -ArgumentList $SafiriDir
        Write-StreamLog "[livekit] LOG STREAM CONNECTED - serveur WebRTC (ws://localhost:7880)"
        Write-StreamLog "[coturn] LOG STREAM CONNECTED - relais TURN (turn:localhost:3478)"
    }

    if (-not $SkipAffiniora -and (Test-Path $AffinioraDir)) {
        $script:LogTailJobs += Start-Job -Name "affiniora-docker" -ScriptBlock {
            param($Dir)
            Set-Location $Dir
            docker compose logs -f --tail=25 ai-engine redis 2>&1
        } -ArgumentList $AffinioraDir
        Write-AffinioraStreamLog -Line "LOG STREAM CONNECTED - Affiniora ai-engine online"
    }

    $global:AfromiaLogTailJobs = $script:LogTailJobs

    $script:LogTailTimer = New-Object System.Timers.Timer
    $script:LogTailTimer.Interval = 300
    $script:LogTailTimer.AutoReset = $true
    $script:LogTailEvent = Register-ObjectEvent -InputObject $script:LogTailTimer -EventName Elapsed -Action {
        foreach ($job in $global:AfromiaLogTailJobs) {
            if ($job.State -ne "Running") { continue }
            $batch = Receive-Job -Job $job -ErrorAction SilentlyContinue
            if (-not $batch) { continue }
            foreach ($raw in @($batch)) {
                if ($null -eq $raw) { continue }
                $text = $raw.ToString().TrimEnd()
                if (-not $text) { continue }
                if ($job.Name -eq "affiniora-docker") {
                    if ($text -match '^\S+\s+\|\s+(.*)$') {
                        Write-AffinioraStreamLog -Line $Matches[1]
                    } else {
                        Write-AffinioraStreamLog -Line $text
                    }
                } else {
                    Write-StreamLog -Line $text
                }
            }
        }
    }
    $script:LogTailTimer.Start()
}

function Stop-CentralizedDockerLogs {
    if ($script:LogTailTimer) {
        $script:LogTailTimer.Stop()
        $script:LogTailTimer.Dispose()
        $script:LogTailTimer = $null
    }
    if ($script:LogTailEvent) {
        Unregister-Event -SourceIdentifier $script:LogTailEvent.Name -ErrorAction SilentlyContinue
        Remove-Job -Name $script:LogTailEvent.Name -Force -ErrorAction SilentlyContinue
        $script:LogTailEvent = $null
    }
    foreach ($job in $script:LogTailJobs) {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
        Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
    }
    $script:LogTailJobs = @()
    $global:AfromiaLogTailJobs = @()
}

function Show-AppLogLegend {
    Write-Host ""
    Write-Host "Couleurs des logs par application (console + logs/latest.log) :" -ForegroundColor DarkGray
    foreach ($app in $script:AppLogColors.Keys) {
        if ($app -eq "celery") { continue }
        $label = $app.PadRight(14)
        Write-Host "  $label" -NoNewline -ForegroundColor $script:AppLogColors[$app]
        if ($app -eq "affiniora" -or $app -eq "ai-engine") {
            Write-Host " [AI] style robot (cyan / magenta inference)" -ForegroundColor DarkGray
        } else {
            Write-Host " [$app]" -ForegroundColor DarkGray
        }
    }
    Write-Host "  Docker infra   postgres, redis, minio, livekit, coturn, celery-worker, celery-beat, ai-engine (flux temps reel)" -ForegroundColor DarkGray
    Write-Host "  Live / WebRTC  livekit (magenta) - coturn/TURN (jaune fonce) - erreurs ICE en rouge" -ForegroundColor DarkGray
    Write-Host ""
}

function Add-PythonScriptsToPath {
    # pip installe uvicorn/alembic dans AppData\Python\Python3xx\Scripts (souvent hors PATH)
    try {
        $pyTag = python -c "import sys; print(f'Python{sys.version_info.major}{sys.version_info.minor}')" 2>$null
        if (-not $pyTag) { return }
        $scriptsDir = Join-Path $env:APPDATA "$pyTag\Scripts"
        if ((Test-Path $scriptsDir) -and ($env:PATH -notlike "*$scriptsDir*")) {
            $env:PATH = "$scriptsDir;$env:PATH"
            Write-AfromiaLog "  PATH Python Scripts : $scriptsDir" -Level info
        }
    } catch {
        # non bloquant
    }
}

function Initialize-AfromiaLog {
    param([string]$Root, [string]$Session = "dev")

    $logDir = Join-Path $Root "logs"
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $script:AfromiaLogFile = Join-Path $logDir "afromia-$Session-$timestamp.log"
    $script:AfromiaLogLatest = Join-Path $logDir "latest.log"
    $global:AfromiaLogFilePath = $script:AfromiaLogFile
    $global:AfromiaLogLatestPath = $script:AfromiaLogLatest

    $header = @"
================================================================================
 AFROMIA - session $Session
 Demarre : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
 Fichier : $script:AfromiaLogFile
================================================================================
"@
    Set-Content -Path $script:AfromiaLogFile -Value $header -Encoding UTF8
    Sync-AfromiaLatestLog -Source $script:AfromiaLogFile -Dest $script:AfromiaLogLatest

    Write-Host ""
    Write-Host $header -ForegroundColor DarkGray
}

function Write-AfromiaLog {
    param(
        [string]$Message,
        [ValidateSet("info", "ok", "warn", "err", "cmd")]
        [string]$Level = "info"
    )

    $ts = Get-Date -Format "HH:mm:ss"
    $line = "[$ts] $Message"

    switch ($Level) {
        "ok"   { Write-Host $line -ForegroundColor Green }
        "warn" { Write-Host $line -ForegroundColor Yellow }
        "err"  { Write-Host $line -ForegroundColor Red }
        "cmd"  { Write-Host $line -ForegroundColor Cyan }
        default { Write-Host $line }
    }

    if ($script:AfromiaLogFile) {
        Add-Content -Path $script:AfromiaLogFile -Value $line -Encoding UTF8
        Sync-AfromiaLatestLog -Source $script:AfromiaLogFile -Dest $script:AfromiaLogLatest
    }
}

function Start-AfromiaStep {
    param(
        [string]$Title,
        [int]$Step = 0,
        [int]$Total = 0
    )

    if ($Step -gt 0) { $script:AfromiaStep = $Step }
    if ($Total -gt 0) { $script:AfromiaStepTotal = $Total }

    $label = if ($script:AfromiaStepTotal -gt 0) {
        "[$script:AfromiaStep/$script:AfromiaStepTotal]"
    } else { "" }

    Write-Host ""
    Write-Host ("-" * 60) -ForegroundColor DarkGray
    Write-AfromiaLog "$label $Title" -Level cmd
    Write-Host ("-" * 60) -ForegroundColor DarkGray
}

function Complete-AfromiaStep {
    param([string]$Title, [TimeSpan]$Elapsed)

    $secs = [math]::Round($Elapsed.TotalSeconds, 1)
    Write-AfromiaLog "[OK] $Title (${secs}s)" -Level ok
}

function Fail-AfromiaStep {
    param([string]$Title, [string]$ErrorMessage)

    Write-AfromiaLog "[FAIL] $Title - $ErrorMessage" -Level err
}

function Invoke-PipInstall {
    param(
        [string]$Label,
        [string]$WorkingDirectory,
        [string]$Extras = "dev",
        [int]$MaxRetries = 3
    )

    $pipArgs = @(
        "install", "-e", ".[$Extras]", "-v",
        "--default-timeout", "600",
        "--retries", "15",
        "--no-warn-script-location"
    )

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Invoke-AfromiaCommand `
                -Label "$Label (tentative $attempt/$MaxRetries)" `
                -Command "python" `
                -Arguments (@("-m", "pip") + $pipArgs) `
                -WorkingDirectory $WorkingDirectory
            return
        } catch {
            Write-AfromiaLog "  Echec pip $attempt/$MaxRetries - nettoyage temp..." -Level warn
            python -m pip cache purge 2>$null | Out-Null
            Get-ChildItem $env:TEMP -Filter "pip-*" -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            if ($attempt -eq $MaxRetries) { throw }
            Start-Sleep -Seconds 8
        }
    }
}

function Invoke-AfromiaCommandOptional {
    param(
        [string]$Label,
        [string]$Command,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $null
    )

    try {
        Invoke-AfromiaCommand -Label $Label -Command $Command -Arguments $Arguments -WorkingDirectory $WorkingDirectory
        return $true
    } catch {
        Write-AfromiaLog "  $Label ignore (non bloquant) : $_" -Level warn
        return $false
    }
}

function Invoke-AfromiaCommand {
    param(
        [string]$Label,
        [string]$Command,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $null,
        [hashtable]$Environment = @{}
    )

    $cmdLine = if ($Arguments.Count -gt 0) {
        "$Command $($Arguments -join ' ')"
    } else { $Command }

    Write-AfromiaLog ">> $Label" -Level cmd
    Write-AfromiaLog "   $cmdLine" -Level info

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $prev = $PWD.Path

    try {
        if ($WorkingDirectory) { Set-Location $WorkingDirectory }

        foreach ($key in $Environment.Keys) {
            Set-Item -Path "env:$key" -Value $Environment[$key]
        }

        # Flux temps reel ligne par ligne (npm verbose ne bloque plus en silence)
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & $Command @Arguments 2>&1 | ForEach-Object {
            $text = $_.ToString()
            Write-StreamLog "   | $text"
        }
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($null -eq $exitCode) { $exitCode = 0 }

        $sw.Stop()

        if ($exitCode -ne 0) {
            Fail-AfromiaStep $Label "code sortie $exitCode"
            throw "Commande echouee ($exitCode): $cmdLine"
        }

        Complete-AfromiaStep $Label $sw.Elapsed
    }
    finally {
        Set-Location $prev
        if ($script:AfromiaLogFile) {
            Sync-AfromiaLatestLog -Source $script:AfromiaLogFile -Dest $script:AfromiaLogLatest
        }
    }
}

# Handlers Register-ObjectEvent s'executent hors scope script
foreach ($fnName in @('Write-AffinioraStreamLog', 'Write-StreamLog', 'Write-StreamLogToFile', 'Get-AfromiaLogPaths', 'Get-AppLogColor', 'Strip-AnsiCodes', 'Sync-AfromiaLatestLog')) {
    $fn = Get-Item "function:$fnName" -ErrorAction SilentlyContinue
    if ($fn) {
        Set-Item "function:global:$fnName" $fn.ScriptBlock
    }
}
