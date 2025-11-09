# scripts/run_import_megantic.ps1
# PowerShell helper: copy the CSV into the running pg container and run the import SQL

param(
  [string]$CsvPath = "IGE487_2025-3-main/TS/J2/Donnees_supplementaires/Herbivorie_Megantic_v04-2017-09-16_mesures.csv",
  [string]$Container = "pg-herbivorie",
  [string]$PgUser = "herbivorie",
  [string]$PgDb = "herbivorie_dev"
)

# Resolve absolute path on Windows (safer)
if (-not (Test-Path -Path $CsvPath)) {
    Write-Error "CSV path not found: $CsvPath"
    exit 1
}

$localPath = (Resolve-Path -Path $CsvPath).Path

Write-Host "Copying $localPath to container $Container:/tmp/megantic_mesures.csv"
& docker cp $localPath "$Container:/tmp/megantic_mesures.csv"

Write-Host "Copying import SQL into container"
$importSql = Join-Path (Get-Location) 'scripts/import_megantic.sql'
if (-not (Test-Path -Path $importSql)) {
    Write-Error "Import SQL not found: $importSql"
    exit 1
}
& docker cp $importSql "$Container:/tmp/import_megantic.sql"

Write-Host "Running import script inside container"
& docker exec -i $Container psql -U $PgUser -d $PgDb -f /tmp/import_megantic.sql

Write-Host "Done. Check staging.megantic in database $PgDb as user $PgUser."
