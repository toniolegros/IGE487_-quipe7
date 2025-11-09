<#
Run all key SQL scripts against a PostgreSQL database (PowerShell helper).

Usage (option A: psql client on host):
  $env:PG_CONN = 'postgresql://postgres:password@localhost:5432/postgres'
  .\run_sql_all.ps1 -Mode psql

Usage (option B: docker container):
  $env:PG_CONTAINER = 'ige487_pg_1'   # name or id of running postgres container
  .\run_sql_all.ps1 -Mode docker

The script will run a predefined ordered list of SQL files. Edit the $filesToRun array
if you need a different order.
#>
param(
    [ValidateSet('psql','docker')]
    [string]$Mode = 'psql'
)

# Ordered list of SQL files to run (relative to repo root). Adjust if needed.
$filesToRun = @(
    'IGE487_2025-3-main/TS/J2/Etapes_anterieures/src/Herbivorie_cre.sql',
    'IGE487_2025-3-main/TS/J2/Etapes_anterieures/src/view.sql',
    'IGE487_2025-3-main/TS/J2/Etapes_anterieures/src/Meteo_cre.sql',
    'IGE487_2025-3-main/TS/J2/Etapes_anterieures/src/IMM.sql',
    'Herbivorie_P2_M2.sql'
)

# Helper: resolve absolute path
function Resolve-RepoPath($p) {
    $root = Get-Location
    return Join-Path $root $p
}

if ($Mode -eq 'psql') {
    if (-not $env:PG_CONN) {
        Write-Error "Environment variable PG_CONN not set. Example: 'postgresql://user:pass@host:5432/db'"
        exit 1
    }
    foreach ($f in $filesToRun) {
        $abs = Resolve-RepoPath $f
        if (-not (Test-Path $abs)) { Write-Warning "File not found: $abs -- skipping"; continue }
        Write-Host "Running $f via psql..."
        & psql $env:PG_CONN -f $abs
        if ($LASTEXITCODE -ne 0) { Write-Error "psql failed for $f (exit $LASTEXITCODE)"; exit $LASTEXITCODE }
    }
    Write-Host "All done (psql mode)."
}
else {
    if (-not $env:PG_CONTAINER) {
        Write-Error "Environment variable PG_CONTAINER not set. Set it to the running Postgres container name or id."
        exit 1
    }
    # Docker execution: honor PG_USER and PG_DB environment variables if set (fallback to postgres)
    $pgUser = if ($env:PG_USER) { $env:PG_USER } else { 'postgres' }
    $pgDb = if ($env:PG_DB) { $env:PG_DB } else { 'postgres' }
    foreach ($f in $filesToRun) {
        $abs = Resolve-RepoPath $f
        if (-not (Test-Path $abs)) { Write-Warning "File not found: $abs -- skipping"; continue }
        $base = [System.IO.Path]::GetFileName($abs)
        try {
            # Resolve absolute path and ensure it exists
            $resolved = Resolve-Path -LiteralPath $abs -ErrorAction Stop
            $absPath = $resolved.Path
        } catch {
            Write-Warning "File not found or path invalid: $abs -- skipping"
            continue
        }
        Write-Host "Copying $absPath to container $env:PG_CONTAINER:/tmp/$base"
        # Use Start-Process to avoid PowerShell quoting issues with docker cp on Windows paths
        $cpCmd = "docker cp `"$absPath`" $env:PG_CONTAINER:/tmp/$base"
        Write-Host "Running: $cpCmd"
        $cpRes = Invoke-Expression $cpCmd
        Write-Host $cpRes
        Write-Host "Executing $base inside container as user $pgUser on db $pgDb"
        $execCmd = "docker exec -i $env:PG_CONTAINER psql -U $pgUser -d $pgDb -f '/tmp/$base'"
        Write-Host "Running: $execCmd"
        $exit = & docker exec -i $env:PG_CONTAINER psql -U $pgUser -d $pgDb -f "/tmp/$base"
        if ($LASTEXITCODE -ne 0) { Write-Error "Command failed inside container for $base (exit $LASTEXITCODE)"; exit $LASTEXITCODE }
        if ($LASTEXITCODE -ne 0) { Write-Error "Command failed inside container for $base (exit $LASTEXITCODE)"; exit $LASTEXITCODE }
    }
    Write-Host "All done (docker mode)."
}
