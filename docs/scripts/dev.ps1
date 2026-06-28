#!/usr/bin/env pwsh
# Lance AFROMIA - build + demarrage avec logs centralises
param(
    [Parameter(Position = 0)]
    [ValidateSet("docker", "local", "supabase")]
    [string]$Mode = "local",

    [switch]$SkipBootstrap,
    [switch]$SkipMigrate,
    [switch]$SkipSeed,
    [switch]$WithSeed,
    [switch]$SkipAffiniora,
    [switch]$PostgresOnly,
    [switch]$WithCelery,
    [switch]$InfraOnly,
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
    [switch]$AffinioraOnly
)

$ErrorActionPreference = "Stop"

function Resolve-TrueCasePath {
    param([string]$InputPath)
    if (-not (Test-Path -LiteralPath $InputPath)) {
        return $InputPath
    }
    $resolved = (Get-Item -LiteralPath $InputPath -Force).FullName
    $root = [System.IO.Path]::GetPathRoot($resolved)
    $rest = $resolved.Substring($root.Length)
    $parts = $rest -split '\\' | Where-Object { $_ }
    $current = $root
    foreach ($part in $parts) {
        $match = Get-ChildItem -LiteralPath $current -Force |
            Where-Object { $_.Name -ieq $part } |
            Select-Object -First 1
        if (-not $match) {
            return $resolved
        }
        $current = Join-Path $current $match.Name
    }
    return $current
}

function Resolve-CanonicalPath {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        return (Resolve-TrueCasePath $Path)
    }
    return $Path
}

$Root = Resolve-CanonicalPath (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)))
$ScriptsDir = Join-Path $Root "docs\scripts"
$SafiriRoot = Resolve-CanonicalPath (Join-Path $Root "SAFIRI")
$AffinioraRoot = Resolve-CanonicalPath (Join-Path $Root "AFFINIORA")
$BackendRoot = Join-Path $SafiriRoot "apps\backend"
$EnvFile = Join-Path $SafiriRoot ".env"

. (Join-Path $ScriptsDir "lib\logging.ps1")
$logSession = if ($InfraOnly) { "local-infra" }
elseif ($BackendOnly) { "local-backend" }
elseif ($FrontendOnly) { "local-frontend" }
elseif ($AffinioraOnly) { "local-affiniora" }
else { $Mode }
Initialize-AfromiaLog -Root $Root -Session $logSession
Add-PythonScriptsToPath

$script:SkipDockerPostgres = $false
$script:PostgresHostPort = 5432
$script:ComposeExtraFilesByDir = @{}

function Initialize-PostgresFromDisk {
    $overridePath = Join-Path $SafiriRoot "docker-compose.postgres-override.yml"
    if (Test-Path -LiteralPath $overridePath) {
        $script:ComposeExtraFilesByDir[$SafiriRoot] = @("docker-compose.postgres-override.yml")
        $raw = Get-Content -LiteralPath $overridePath -Raw
        if ($raw -match '"(\d+):5432"') {
            $script:PostgresHostPort = [int]$Matches[1]
            Write-AfromiaLog "  Override postgres detecte (port $($script:PostgresHostPort))" -Level info
        }
    }

    if (Test-Path -LiteralPath $EnvFile) {
        $envRaw = Get-Content -LiteralPath $EnvFile -Raw
        if ($envRaw -match 'localhost:(\d+)/afromia') {
            $envPort = [int]$Matches[1]
            if ($envPort -ne $script:PostgresHostPort) {
                Write-AfromiaLog "  DATABASE_URL indique le port $envPort" -Level info
            }
        }
    }
}

Initialize-PostgresFromDisk

function Get-PostgresCandidatePorts {
    $ports = [ordered]@{ 5432 = $true; 5433 = $true; 5434 = $true; 5435 = $true; 5436 = $true }
    $overridePath = Join-Path $SafiriRoot "docker-compose.postgres-override.yml"
    if (Test-Path -LiteralPath $overridePath) {
        $raw = Get-Content -LiteralPath $overridePath -Raw
        if ($raw -match '"(\d+):5432"') {
            $hint = [int]$Matches[1]
            $ordered = [ordered]@{ $hint = $true }
            foreach ($p in $ports.Keys) {
                if ($p -ne $hint) { $ordered[$p] = $true }
            }
            return @($ordered.Keys)
        }
    }
    return @($ports.Keys)
}

function Test-AnyPostgresAuth {
    foreach ($port in (Get-PostgresCandidatePorts)) {
        if (Test-AfromiaPostgresAuth -Port $port) {
            $script:PostgresHostPort = $port
            return $true
        }
    }
    return $false
}

function Test-AnyPostgresReady {
    foreach ($port in (Get-PostgresCandidatePorts)) {
        if (Test-PostgresExtensionsReady -Port $port) {
            $script:PostgresHostPort = $port
            return $true
        }
    }
    return $false
}

function Test-PostgresContainerPresent {
    Push-Location $SafiriRoot
    try {
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $fileArgs = Get-ComposeFileArgs -ComposeDir $SafiriRoot
        $status = (docker compose @fileArgs ps postgres 2>&1 | Out-String).Trim()
        $ErrorActionPreference = $prevEap
        return [bool]($status -match '(?i)running|up \(')
    }
    finally {
        Pop-Location
    }
}

function Write-PostgresWaitHint {
    Push-Location $SafiriRoot
    try {
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $fileArgs = Get-ComposeFileArgs -ComposeDir $SafiriRoot
        $status = (docker compose @fileArgs ps postgres 2>&1 | Out-String).Trim()
        $ErrorActionPreference = $prevEap
        if ($status -match '(?i)running|up') {
            Write-AfromiaLog "  Conteneur postgres demarre - attente connexion..." -Level info
        } elseif ($status -match '(?i)starting|created|health') {
            Write-AfromiaLog "  Conteneur postgres en cours de demarrage..." -Level info
        } elseif ($status) {
            Write-AfromiaLog "  Etat docker postgres : $($status -replace '\s+', ' ')" -Level info
        } else {
            Write-AfromiaLog "  Aucun conteneur postgres - lancez make dev-infra (fenetre 1 du split)" -Level warn
        }
    }
    finally {
        Pop-Location
    }
}

function Write-DevInfraReadyMarker {
    $cacheDir = Join-Path $SafiriRoot ".cache"
    New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
    $marker = Join-Path $cacheDir "dev-infra.ready"
    Set-Content -Path $marker -Value "$($script:PostgresHostPort) $(Get-Date -Format 'o')" -Encoding UTF8
}

function Clear-DevInfraReadyMarker {
    $marker = Join-Path $SafiriRoot ".cache\dev-infra.ready"
    if (Test-Path -LiteralPath $marker) {
        Remove-Item -LiteralPath $marker -Force
    }
}

function Read-DevInfraReadyMarker {
    $marker = Join-Path $SafiriRoot ".cache\dev-infra.ready"
    if (-not (Test-Path -LiteralPath $marker)) { return $false }
    $line = (Get-Content -LiteralPath $marker -Raw).Trim()
    if ($line -match '^(\d+)\s') {
        $script:PostgresHostPort = [int]$Matches[1]
    }
    return $true
}

function Wait-AnyPostgresReady {
    param(
        [int]$MaxAttempts = 90,
        [int]$SleepSeconds = 2
    )

    if (Read-DevInfraReadyMarker) {
        Write-AfromiaLog "  Marqueur dev-infra.ready (port $($script:PostgresHostPort)) - verification connexion..." -Level info
    }

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        if (Test-AnyPostgresAuth) {
            Write-AfromiaLog "  Postgres pret sur port $($script:PostgresHostPort)" -Level ok
            return $true
        }
        if ($i -lt $MaxAttempts) {
            if ($i -eq 1 -or ($i % 5) -eq 0) {
                Write-AfromiaLog "  Attente Postgres ($i/$MaxAttempts) - dev-infra peut etre en cours..." -Level info
                Write-PostgresWaitHint
            }
            Start-Sleep -Seconds $SleepSeconds
        }
    }
    return $false
}

function Ensure-PostgresForLocalApps {
    param([string]$ComposeDir)

    if (Test-AnyPostgresAuth) {
        Write-AfromiaLog "  Postgres pret sur port $($script:PostgresHostPort)" -Level ok
        Apply-PostgresEnv
        return $true
    }

    if (Test-PostgresContainerPresent) {
        Write-AfromiaLog "  Conteneur postgres detecte - attente connexion..." -Level info
        if (Wait-AnyPostgresReady -MaxAttempts 45) {
            Apply-PostgresEnv
            return $true
        }
        Write-AfromiaLog "  Conteneur postgres present mais injoignable - redemarrage..." -Level warn
        Stop-And-Remove-PostgresContainer -ComposeDir $ComposeDir
    }

    if (Read-DevInfraReadyMarker) {
        Write-AfromiaLog "  Marqueur dev-infra.ready obsolete (postgres injoignable) - relance infra..." -Level warn
        Clear-DevInfraReadyMarker
    }

    if (Test-HostPostgresPort -Port 5432) {
        Write-AfromiaLog "  Port 5432 occupe mais compte afromia injoignable (service zombie ou autre PostgreSQL)" -Level warn
        Write-AfromiaLog "  Docker basculera sur un port libre (5433+) si necessaire" -Level info
    }

    Write-AfromiaLog "  Demarrage infra Docker (postgres, redis, minio, livekit, coturn)..." -Level info
    Write-AfromiaLog "  Astuce : plus besoin de make dev-infra dans un 2e terminal - ce terminal suffit" -Level ok
    Start-DockerInfra -Label "Infra SAFIRI (postgres, redis, minio, livekit, coturn)" `
        -Services @("postgres", "redis", "minio", "livekit", "coturn") -ComposeDir $ComposeDir
    Wait-PostgresReady -ComposeDir $ComposeDir
    Invoke-Migrate
    Write-DevInfraReadyMarker
    Apply-PostgresEnv
    return $true
}

function Ensure-Env {
    if (-not (Test-Path $EnvFile)) {
        Write-AfromiaLog "Fichier .env absent - configuration profil '$Mode'..." -Level warn
        $setupScript = Join-Path $ScriptsDir "setup-env.ps1"
        if (Test-Path $setupScript) {
            & $setupScript $Mode
        } else {
            $safiriSetup = Join-Path $SafiriRoot "scripts\setup-env.ps1"
            if (Test-Path $safiriSetup) { & $safiriSetup $Mode }
        }
    }
}

function Get-ComposeFileArgs {
    param([string]$ComposeDir)

    $extras = @()
    if ($ComposeDir -and $script:ComposeExtraFilesByDir.ContainsKey($ComposeDir)) {
        $extras = $script:ComposeExtraFilesByDir[$ComposeDir]
    } elseif ($ComposeDir) {
        $overridePath = Join-Path $ComposeDir "docker-compose.postgres-override.yml"
        if (Test-Path -LiteralPath $overridePath) {
            $extras = @("docker-compose.postgres-override.yml")
        }
    }

    if ($extras.Count -eq 0) {
        return @()
    }
    $fileArgs = @("-f", "docker-compose.yml")
    foreach ($extra in $extras) {
        $fileArgs += @("-f", $extra)
    }
    return $fileArgs
}

function Wait-Postgres {
    param([string]$ComposeDir)

    Push-Location $ComposeDir
    Write-AfromiaLog "Attente PostgreSQL..." -Level info

    $fileArgs = Get-ComposeFileArgs -ComposeDir $ComposeDir
    $attempts = 0
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    while ($attempts -lt 30) {
        $cid = docker compose @fileArgs ps -q postgres 2>&1
        if ($cid) {
            docker exec $cid pg_isready -U afromia 2>&1 | ForEach-Object {
                Write-StreamLog "[postgres] $_"
            }
            if ($LASTEXITCODE -eq 0) {
                $ErrorActionPreference = $prevEap
                Pop-Location
                Write-AfromiaLog "PostgreSQL pret" -Level ok
                return
            }
        }
        Start-Sleep -Seconds 2
        $attempts++
        Write-AfromiaLog "  tentative $attempts/30..." -Level info
    }
    $ErrorActionPreference = $prevEap
    Pop-Location
    throw "PostgreSQL n'est pas pret apres 60s"
}

function Test-DockerImageLocal {
    param([string]$ImageRef)
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $null = docker image inspect $ImageRef 2>&1
        return $LASTEXITCODE -eq 0
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Get-DockerImageList {
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $out = docker images --format "{{.Repository}}:{{.Tag}}" 2>&1
        return @($out | Where-Object { $_ -is [string] -and $_ -match ':' -and $_ -notmatch '^(error|Error)' })
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Find-BestLocalPostgresImage {
    $images = Get-DockerImageList
    $patterns = @(
        '^afromia-postgres:',
        '^garapadev/postgres-postgis',
        '^postgis/postgis:16',
        '^postgis/postgis:',
        '^postgres:16',
        '^postgres:15',
        '^postgres:latest'
    )
    foreach ($pattern in $patterns) {
        $match = $images | Where-Object { $_ -match $pattern } | Select-Object -First 1
        if ($match) { return $match }
    }
    return $null
}

function Test-HostPostgresPort {
    param([int]$Port = 5432)

    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect("127.0.0.1", $Port, $null, $null)
        $ok = $connect.AsyncWaitHandle.WaitOne(2000, $false)
        if ($ok -and $tcp.Connected) {
            $tcp.Close()
            return $true
        }
        $tcp.Close()
    } catch {}
    return $false
}

function Test-AfromiaPostgresAuth {
    param([int]$Port = 5432)

    if (-not (Test-HostPostgresPort -Port $Port)) { return $false }

    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $py = @"
import sys
try:
    import psycopg
    conn = psycopg.connect('postgresql://afromia:afromia@127.0.0.1:$Port/afromia', connect_timeout=3)
    conn.close()
    sys.exit(0)
except Exception:
    sys.exit(1)
"@
        python -c $py 2>&1 | Out-Null
        return $LASTEXITCODE -eq 0
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Test-PostgresExtensionsReady {
    param([int]$Port = 5432)

    if (-not (Test-AfromiaPostgresAuth -Port $Port)) { return $false }

    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $py = @"
import sys
try:
    import psycopg
    conn = psycopg.connect('postgresql://afromia:afromia@127.0.0.1:$Port/afromia', connect_timeout=3)
    cur = conn.cursor()
    for ext in ('postgis', 'vector'):
        cur.execute("SELECT 1 FROM pg_available_extensions WHERE name = %s", (ext,))
        if not cur.fetchone():
            sys.exit(1)
        cur.execute(f"CREATE EXTENSION IF NOT EXISTS {ext}")
    conn.commit()
    conn.close()
    sys.exit(0)
except Exception:
    sys.exit(1)
"@
        python -c $py 2>&1 | Out-Null
        return $LASTEXITCODE -eq 0
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
}

function Ensure-AfromiaPostgresImage {
    param([string]$ComposeDir)

    if (Test-DockerImageLocal "afromia-postgres:16") { return }
    if (Test-DockerImageLocal "garapadev/postgres-postgis-pgvector:16-stable") { return }

    if (-not (Test-DockerImageLocal "postgis/postgis:16-3.4")) {
        Write-AfromiaLog "  Image postgis/postgis:16-3.4 absente - tentative pull..." -Level warn
        Invoke-AfromiaCommandOptional `
            -Label "docker pull postgis/postgis:16-3.4" `
            -Command "docker" `
            -Arguments @("pull", "postgis/postgis:16-3.4")
    }

    if (-not (Test-DockerImageLocal "postgis/postgis:16-3.4")) {
        throw "Impossible de construire afromia-postgres:16 sans postgis/postgis:16-3.4"
    }

    Write-AfromiaLog "  Build image afromia-postgres:16 (PostGIS + pgvector)..." -Level info
    Push-Location $ComposeDir
    Invoke-AfromiaCommand `
        -Label "docker build afromia-postgres:16" `
        -Command "docker" `
        -Arguments @("build", "-f", "infra/docker/Dockerfile.postgres", "-t", "afromia-postgres:16", ".")
    Pop-Location
}

function Stop-And-Remove-PostgresContainer {
    param([string]$ComposeDir)

    Push-Location $ComposeDir
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    docker compose stop postgres 2>&1 | Out-Null
    docker compose rm -f postgres 2>&1 | Out-Null
    $ErrorActionPreference = $prevEap
    Pop-Location
}

function Remove-PostgresComposeOverride {
    param([string]$ComposeDir)

    $overridePath = Join-Path $ComposeDir "docker-compose.postgres-override.yml"
    if (Test-Path $overridePath) {
        Remove-Item $overridePath -Force
    }
    $script:ComposeExtraFilesByDir.Remove($ComposeDir) | Out-Null
}

function Find-FreePostgresHostPort {
    param([int]$StartPort = 5433, [int]$MaxAttempts = 10)

    for ($port = $StartPort; $port -lt ($StartPort + $MaxAttempts); $port++) {
        if (-not (Test-HostPostgresPort -Port $port)) {
            return $port
        }
    }
    throw "Aucun port Postgres libre entre $StartPort et $($StartPort + $MaxAttempts - 1)"
}

function Write-PostgresComposeOverride {
    param(
        [string]$ComposeDir,
        [string]$Image,
        [int]$HostPort = 5432
    )

    $overridePath = Join-Path $ComposeDir "docker-compose.postgres-override.yml"
    $lines = @(
        "# Genere automatiquement par make dev",
        "services:",
        "  postgres:"
    )
    if ($Image) {
        $lines += "    image: $Image"
    }
    if ($HostPort -ne 5432) {
        # !override remplace le mapping 5432 du docker-compose.yml de base
        $lines += "    ports: !override"
        $lines += "      - `"$HostPort`:5432`""
    }
    ($lines -join "`n") | Set-Content -Path $overridePath -Encoding UTF8

    $script:ComposeExtraFilesByDir[$ComposeDir] = @($overridePath)
    $details = @()
    if ($Image) { $details += $Image }
    if ($HostPort -ne 5432) { $details += "port $HostPort" }
    Write-AfromiaLog "  Override compose : $($details -join ', ')" -Level ok
}

function Finalize-DockerPostgresSetup {
    param([string]$ComposeDir, [string]$Image = $null, [string]$Label = "cache local")

    if (-not $Image -and $script:PostgresHostPort -eq 5432) {
        Remove-PostgresComposeOverride -ComposeDir $ComposeDir
        Write-AfromiaLog "  Postgres Docker : afromia-postgres:16 (port 5432 par defaut)" -Level ok
        return
    }

    Write-PostgresComposeOverride -ComposeDir $ComposeDir -Image $Image -HostPort $script:PostgresHostPort
    if ($Image) { Warn-PostgresImageLimitations -Image $Image }

    if ($Image) {
        $portInfo = if ($script:PostgresHostPort -eq 5432) { "port 5432" } else { "port $($script:PostgresHostPort)" }
        Write-AfromiaLog "  Postgres Docker : $Image ($Label, $portInfo)" -Level ok
    } else {
        Write-AfromiaLog "  Postgres Docker : afromia-postgres:16 (port $($script:PostgresHostPort))" -Level ok
    }
}

function Show-DockerDnsHelp {
    Write-AfromiaLog "" -Level err
    Write-AfromiaLog "DOCKER HUB inaccessible (DNS/reseau) et aucune image Postgres locale." -Level err
    Write-AfromiaLog "Solutions :" -Level err
    Write-AfromiaLog "  A) Docker Desktop > Settings > Docker Engine :" -Level err
    Write-AfromiaLog '     "dns": ["8.8.8.8", "1.1.1.1"]  puis Apply & Restart' -Level err
    Write-AfromiaLog "  B) Puis : docker pull postgis/postgis:16-3.4" -Level err
    Write-AfromiaLog "  C) Installer PostgreSQL sur Windows (port 5432) puis relancer make dev" -Level err
    Write-AfromiaLog "  Voir docs/TROUBLESHOOTING.md" -Level err
}

function Resolve-PostgresStrategy {
    param([string]$ComposeDir)

    $script:PostgresHostPort = 5432
    Remove-PostgresComposeOverride -ComposeDir $ComposeDir

    if (Test-PostgresExtensionsReady -Port 5432) {
        $script:SkipDockerPostgres = $true
        Write-AfromiaLog "  PostgreSQL AFROMIA pret sur localhost:5432 (PostGIS + pgvector OK)" -Level ok
        return
    }

    if (Test-AfromiaPostgresAuth -Port 5432) {
        Write-AfromiaLog "  Postgres afromia sur :5432 mais PostGIS/pgvector manquant" -Level warn
        Write-AfromiaLog "  Recreation du conteneur avec afromia-postgres:16" -Level info
        Stop-And-Remove-PostgresContainer -ComposeDir $ComposeDir
    }

    Ensure-AfromiaPostgresImage -ComposeDir $ComposeDir

    if (Test-HostPostgresPort -Port 5432) {
        $altPort = Find-FreePostgresHostPort
        Write-AfromiaLog "  Port 5432 occupe par un autre service - bascule sur le port $altPort" -Level warn
        $script:PostgresHostPort = $altPort
    } else {
        Write-AfromiaLog "  Port 5432 libre - Postgres Docker sur le port par defaut" -Level ok
    }

    $known = @(
        "afromia-postgres:16",
        "garapadev/postgres-postgis-pgvector:16-stable",
        "postgis/postgis:16-3.4",
        "postgres:16-alpine",
        "postgres:16",
        "postgres:15",
        "postgres:latest"
    )
    foreach ($img in $known) {
        if (Test-DockerImageLocal $img) {
            $overrideImage = if ($img -ne "afromia-postgres:16") { $img } else { $null }
            Finalize-DockerPostgresSetup -ComposeDir $ComposeDir -Image $overrideImage
            return
        }
    }

    $discovered = Find-BestLocalPostgresImage
    if ($discovered) {
        Finalize-DockerPostgresSetup -ComposeDir $ComposeDir -Image $discovered -Label "cache local detecte"
        return
    }

    Write-AfromiaLog "  Postgres Docker absent - tentative pull..." -Level warn
    Push-Location $ComposeDir
    Invoke-AfromiaCommandOptional `
        -Label "docker compose pull postgres" `
        -Command "docker" `
        -Arguments @("compose", "pull", "postgres")
    Pop-Location

    if (Test-DockerImageLocal "afromia-postgres:16") {
        Finalize-DockerPostgresSetup -ComposeDir $ComposeDir
        return
    }

    $discovered = Find-BestLocalPostgresImage
    if ($discovered) {
        Finalize-DockerPostgresSetup -ComposeDir $ComposeDir -Image $discovered -Label "apres pull partiel"
        return
    }

    Show-DockerDnsHelp
    throw "Postgres indisponible : ni image Docker locale, ni pull, ni auth afromia sur :5432"
}

function Warn-PostgresImageLimitations {
    param([string]$Image)

    if ($Image -notmatch 'postgis|garapadev') {
        Write-AfromiaLog "  ATTENTION : $Image sans PostGIS/pgvector - migrations Alembic peuvent echouer" -Level warn
        Write-AfromiaLog "  Quand le reseau revient : docker pull postgis/postgis:16-3.4" -Level warn
    }
}

function Ensure-DockerImages {
    param([string]$ComposeDir)

    $infraMissing = @()
    foreach ($entry in @(
            @{ Service = "redis"; Image = "redis:7-alpine" },
            @{ Service = "minio"; Image = "minio/minio:latest" },
            @{ Service = "livekit"; Image = "livekit/livekit-server:latest" },
            @{ Service = "coturn"; Image = "coturn/coturn:latest" }
        )) {
        if (Test-DockerImageLocal $entry.Image) {
            Write-AfromiaLog "  OK cache local : $($entry.Image)" -Level ok
        } else {
            $infraMissing += $entry.Service
        }
    }

    if ($infraMissing.Count -gt 0) {
        Write-AfromiaLog "  Images infra manquantes : $($infraMissing -join ', ') - tentative pull..." -Level warn
        Push-Location $ComposeDir
        Invoke-AfromiaCommandOptional `
            -Label "docker compose pull $($infraMissing -join ' ')" `
            -Command "docker" `
            -Arguments (@("compose", "pull") + $infraMissing)
        Pop-Location
    }

    Resolve-PostgresStrategy -ComposeDir $ComposeDir
}

function Get-ComposeArguments {
    param(
        [string[]]$Services,
        [string]$ComposeDir
    )

    $args = @("compose") + (Get-ComposeFileArgs -ComposeDir $ComposeDir) + @("up", "-d") + $Services
    return $args
}

function Wait-PostgresReady {
    param([string]$ComposeDir)

    if ($script:SkipDockerPostgres) {
        $port = $script:PostgresHostPort
        Write-AfromiaLog "Attente PostgreSQL local :$port..." -Level info
        for ($i = 1; $i -le 15; $i++) {
            if (Test-AfromiaPostgresAuth -Port $port) {
                Write-AfromiaLog "PostgreSQL local pret (port $port)" -Level ok
                return
            }
            Start-Sleep -Seconds 2
        }
        throw "PostgreSQL local :$port non accessible (user afromia)"
    }

    Wait-Postgres -ComposeDir $ComposeDir
}

function Start-DockerInfra {
    param([string]$Label, [string[]]$Services, [string]$ComposeDir)

    Start-AfromiaStep -Title $Label
    Push-Location $ComposeDir

    if ($Services -contains "postgres") {
        Ensure-DockerImages -ComposeDir $ComposeDir
        if ($script:SkipDockerPostgres) {
            $Services = @($Services | Where-Object { $_ -ne "postgres" })
        }
    } else {
        Invoke-AfromiaCommandOptional `
            -Label "docker compose pull ($($Services -join ' '))" `
            -Command "docker" `
            -Arguments (@("compose", "pull") + $Services)
    }

    $composeArgs = Get-ComposeArguments -Services $Services -ComposeDir $ComposeDir
    Invoke-AfromiaCommand `
        -Label "docker compose up ($($Services -join ', '))" `
        -Command "docker" `
        -Arguments $composeArgs
    Pop-Location
}

function Apply-PostgresEnv {
    if ($Mode -eq "docker" -or $Mode -eq "local" -or $Mode -eq "supabase") {
        $port = $script:PostgresHostPort
        $env:DATABASE_URL = "postgresql+asyncpg://afromia:afromia@localhost:${port}/afromia"
        $env:DATABASE_URL_SYNC = "postgresql+psycopg://afromia:afromia@localhost:${port}/afromia"
        $env:DATABASE_SSL = "false"
        if ($port -ne 5432) {
            Write-AfromiaLog "  DATABASE_URL -> localhost:$port (port 5432 occupe)" -Level warn
        }
    }
    $env:ENV_FILE = $EnvFile
}

function Set-MigrateEnv {
    Apply-PostgresEnv
}

function Invoke-Migrate {
    if ($SkipMigrate) {
        Write-AfromiaLog "Migrations ignorees (-SkipMigrate)" -Level warn
        return
    }
    Start-AfromiaStep -Title "Migrations Alembic"
    Set-MigrateEnv
    Invoke-AfromiaCommand `
        -Label "alembic upgrade head" `
        -Command "python" `
        -Arguments @("-m", "alembic", "upgrade", "head") `
        -WorkingDirectory $BackendRoot
}

function Invoke-Seed {
    if (-not $WithSeed) {
        Write-AfromiaLog 'Fixtures non chargees au demarrage - utilisez le Debug Panel (Ctrl+Shift+D) ou: make seed' -Level info
        return
    }
    if ($SkipSeed) {
        Write-AfromiaLog "Seed ignore (-SkipSeed)" -Level warn
        return
    }
    Start-AfromiaStep -Title "Fixtures / seed (idempotent)"
    Set-MigrateEnv
    Invoke-AfromiaCommand `
        -Label "seed_data.py" `
        -Command "python" `
        -Arguments @("scripts/seed_data.py") `
        -WorkingDirectory $BackendRoot
}

function Show-Urls {
    param([switch]$CelerySkipped)

    Write-Host ""
    Write-AfromiaLog "===========================================================" -Level ok
    Write-AfromiaLog "  Frontend  : http://localhost:3000" -Level ok
    Write-AfromiaLog "  Backend   : http://localhost:8000/docs" -Level ok
    Write-AfromiaLog "  Affiniora : http://localhost:8001/docs" -Level ok
    Write-AfromiaLog "  MinIO     : http://localhost:9001  (minioadmin/minioadmin)" -Level ok
    Write-AfromiaLog "  LiveKit   : ws://localhost:7880" -Level ok
    Write-AfromiaLog "  TURN      : turn:localhost:3478" -Level ok
    if ($CelerySkipped) {
        Write-AfromiaLog "  Celery    : OFF - autre terminal : make celery" -Level warn
    } else {
        Write-AfromiaLog "  Celery    : Docker (celery-worker + celery-beat)" -Level ok
    }
    Write-AfromiaLog "  Logs      : $script:AfromiaLogLatest" -Level ok
    Write-AfromiaLog "===========================================================" -Level ok
    Write-Host ""
}

function Start-CeleryDocker {
    param([switch]$Build)

    Write-AfromiaLog '>> Celery worker+beat (Docker)' -Level cmd
    Push-Location $SafiriRoot
    try {
        $composeArgs = @("compose") + (Get-ComposeFileArgs -ComposeDir $SafiriRoot) + @("up", "-d")
        if ($Build) {
            $composeArgs += "--build"
        }
        $composeArgs += @("celery-worker", "celery-beat")
        Invoke-AfromiaCommand `
            -Label "docker compose up celery-worker celery-beat" `
            -Command "docker" `
            -Arguments $composeArgs
    }
    finally {
        Pop-Location
    }
}

function Start-LocalApps {
    param(
        [switch]$TailAffiniora,
        [ValidateSet("both", "backend", "frontend")]
        [string]$Apps = "both"
    )

    $appLabel = switch ($Apps) {
        "backend"  { "backend seul" }
        "frontend" { "frontend seul" }
        default    { "backend + frontend" }
    }
    $npmScript = switch ($Apps) {
        "backend"  { "dev:backend" }
        "frontend" { "dev:frontend" }
        default    { "dev:local" }
    }

    Start-AfromiaStep -Title "Demarrage apps locales ($appLabel + logs Docker)"
    Show-Urls -CelerySkipped:(-not $WithCelery)

    Apply-PostgresEnv
    $env:INIT_CWD = $SafiriRoot
    if ($WithCelery) {
        Start-CeleryDocker
    } elseif ($Apps -ne "frontend") {
        Write-AfromiaLog "Celery non demarre (evite le build Docker bloquant) - autre terminal : make celery" -Level info
    }
    if ($Apps -eq "both") {
        Write-AfromiaLog '>> npm run dev:local (concurrently [backend] + [frontend], decouples en cas de crash backend)' -Level cmd
    } else {
        Write-AfromiaLog ">> npm run $npmScript (processus isole - autres services dans un autre terminal)" -Level cmd
    }
    Write-AfromiaLog '>> docker compose logs -f (postgres, redis, minio, livekit, coturn, celery, ai-engine)' -Level cmd
    Write-AfromiaLog "  Racine canonique : $SafiriRoot" -Level info
    Show-AppLogLegend

    Push-Location $SafiriRoot
    try {
        Start-CentralizedDockerLogs -SafiriDir $SafiriRoot -AffinioraDir $AffinioraRoot -SkipAffiniora:(-not $TailAffiniora)

        # Ne pas piper npm : sous PowerShell Windows, la rupture de pipe tue le watchdog Node silencieusement.
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & npm run $npmScript
        $npmExit = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($null -eq $npmExit) { $npmExit = 0 }
        if ($npmExit -ne 0) {
            throw "npm run $npmScript a echoue (code $npmExit)"
        }
    }
    finally {
        Stop-CentralizedDockerLogs
        Pop-Location
    }
}

function Start-DockerCompose {
    param([string]$ComposeFile, [string]$WorkingDir)

    Start-AfromiaStep -Title "Docker Compose - build + demarrage (flux continu)"
    Push-Location $WorkingDir
    try {
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        Show-AppLogLegend
        docker compose -f $ComposeFile up --build 2>&1 | ForEach-Object {
            Write-StreamLog $_.ToString()
        }
        $ErrorActionPreference = $prevEap
    }
    finally {
        Pop-Location
    }
}

if (-not $SkipBootstrap) {
    $nodeModules = Join-Path $SafiriRoot "node_modules"
    if (-not (Test-Path $nodeModules)) {
        Write-AfromiaLog "Premier lancement - bootstrap automatique..." -Level warn
        & (Join-Path $ScriptsDir "bootstrap.ps1")
    }
}

Ensure-Env

Write-AfromiaLog "Mode : $Mode" -Level cmd

switch ($Mode) {
    "docker" {
        Write-AfromiaLog "=== Mode DOCKER (stack complet) ===" -Level cmd

        if (-not $SkipMigrate) {
            Start-DockerInfra -Label "Infra SAFIRI (postgres, redis, minio, livekit, coturn)" `
                -Services @("postgres", "redis", "minio", "livekit", "coturn") -ComposeDir $SafiriRoot
            Wait-PostgresReady -ComposeDir $SafiriRoot
            Invoke-Migrate
            Invoke-Seed
        }

        if (-not $SkipAffiniora) {
            Start-DockerInfra -Label "AFFINIORA (redis + ai-engine)" `
                -Services @("redis", "ai-engine") -ComposeDir $AffinioraRoot
        }

        Show-Urls

        $composeFile = Join-Path $Root "docker-compose.yml"
        if (-not (Test-Path $composeFile)) {
            $composeFile = Join-Path $Root "docs\docker-compose.ecosystem.yml"
        }

        if (Test-Path $composeFile) {
            Start-DockerCompose -ComposeFile $composeFile -WorkingDir $Root
        } else {
            Push-Location $SafiriRoot
            docker compose up --build
            Pop-Location
        }
    }

    "local" {
        if ($BackendOnly -and $FrontendOnly) {
            throw "Utilisez -BackendOnly OU -FrontendOnly, pas les deux."
        }

        if ($AffinioraOnly) {
            & (Join-Path $ScriptsDir "affiniora.ps1")
            return
        }

        if ($FrontendOnly) {
            Write-AfromiaLog "=== Mode FRONTEND SEUL (infra/backend dans un autre terminal) ===" -Level cmd
            Apply-PostgresEnv
            Start-LocalApps -Apps frontend
            return
        }

        if ($BackendOnly) {
            Write-AfromiaLog "=== Mode BACKEND SEUL ===" -Level cmd
            if (-not (Ensure-PostgresForLocalApps -ComposeDir $SafiriRoot)) {
                throw "PostgreSQL indisponible - verifiez Docker Desktop puis relancez make dev-backend"
            }
            Start-LocalApps -Apps backend
            return
        }

        if ($PostgresOnly -or $InfraOnly) {
            $label = if ($InfraOnly) { "INFRA SEUL (Postgres + services Docker)" } else { "LOCAL LEGER (Postgres Docker seul)" }
            Write-AfromiaLog "=== Mode $label ===" -Level cmd
            if ($InfraOnly) {
                Start-DockerInfra -Label "Infra SAFIRI (postgres, redis, minio, livekit, coturn)" `
                    -Services @("postgres", "redis", "minio", "livekit", "coturn") -ComposeDir $SafiriRoot
            } else {
                Start-DockerInfra -Label "PostgreSQL Docker" -Services @("postgres") -ComposeDir $SafiriRoot
            }
            Wait-PostgresReady -ComposeDir $SafiriRoot
            Invoke-Migrate
            Invoke-Seed
            Show-Urls -CelerySkipped:(-not $WithCelery)
            Write-DevInfraReadyMarker
            Write-AfromiaLog "Infra prete - autres terminaux :" -Level ok
            Write-AfromiaLog "  make dev-backend   make dev-frontend   make dev-affiniora (optionnel)" -Level ok
            return
        }

        Write-AfromiaLog "=== Mode LOCAL (infra Docker + apps locales) ===" -Level cmd
        Start-DockerInfra -Label "Infra SAFIRI (postgres, redis, minio, livekit, coturn)" `
            -Services @("postgres", "redis", "minio", "livekit", "coturn") -ComposeDir $SafiriRoot

        if (-not $SkipAffiniora) {
            Start-DockerInfra -Label "AFFINIORA (redis + ai-engine)" `
                -Services @("redis", "ai-engine") -ComposeDir $AffinioraRoot
        }

        Wait-PostgresReady -ComposeDir $SafiriRoot
        Invoke-Migrate
        Invoke-Seed

        Start-LocalApps -TailAffiniora:(-not $SkipAffiniora) -Apps both
    }

    "supabase" {
        Write-AfromiaLog "=== Mode SUPABASE ===" -Level cmd
        $envContent = Get-Content $EnvFile -Raw
        if ($envContent -match '\[PROJECT_REF\]|\[PASSWORD\]|\[REGION\]') {
            throw "Configurez SAFIRI\.env avec vos identifiants Supabase (docs\scripts\setup-env.ps1 supabase)"
        }

        Start-DockerInfra -Label "Redis + MinIO + LiveKit + coturn" `
            -Services @("redis", "minio", "livekit", "coturn") -ComposeDir $SafiriRoot

        if (-not $SkipAffiniora) {
            Start-DockerInfra -Label "AFFINIORA" -Services @("redis", "ai-engine") -ComposeDir $AffinioraRoot
        }

        Invoke-Migrate
        Invoke-Seed
        Start-LocalApps -TailAffiniora:(-not $SkipAffiniora)
    }
}
