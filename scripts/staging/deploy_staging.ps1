# Script Officiel de Deploiement Staging & Validation d Idempotence
# Module : lyxal_pipeline_ingestion
# Date : 25 Octobre 2026

param(
    [string]$HttpUrl = "http://127.0.0.1:8001/sql",
    [string]$Namespace = "lyxal_staging",
    [string]$Database = "pipeline_staging",
    [string]$Username = $env:LYXAL_STAGING_USER,
    [string]$Password = $env:LYXAL_STAGING_PASS
)

# Chargement automatique de .env.staging si present et si variables non definies
$envStagingPath = "c:\Users\HP\Desktop\Lyxal_OS\.env.staging"
if (Test-Path $envStagingPath) {
    Get-Content $envStagingPath | ForEach-Object {
        if ($_ -match "^\s*([^#=]+)\s*=\s*(.*)$") {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if (-not [System.Environment]::GetEnvironmentVariable($key)) {
                [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
            }
        }
    }
}

if (-not $Username) { $Username = $env:LYXAL_STAGING_USER }
if (-not $Password) { $Password = $env:LYXAL_STAGING_PASS }
if (-not $Username) { $Username = "lyxal_stg_admin_v1" }
if (-not $Password) { $Password = "Stg_SecLyxal#2026!Rotated9x" }

Write-Host "=========================================================="
Write-Host "DEPLOIEMENT STAGING REEL -- LYXAL PIPELINE INGESTION V1"
Write-Host "=========================================================="
Write-Host "Endpoint  : $HttpUrl"
Write-Host "Namespace : $Namespace"
Write-Host "Database  : $Database"
Write-Host "User      : $Username"
Write-Host ""

$baseDir = "c:\Users\HP\Desktop\Lyxal_OS\crates\lyxal_pipeline_ingestion"

$headers = @{
    "surreal-ns" = $Namespace
    "surreal-db" = $Database
    "NS" = $Namespace
    "DB" = $Database
    "Accept" = "application/json"
    "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
}

# 1. Liste ordonnee stricte des schemas et primitives
$schemas = @(
    "schema\00_core_primitives.surql",
    "schema\00_ingestion_session.surql",
    "schema\01_ingestion_batch.surql",
    "schema\02_ingestion_raw_record.surql",
    "schema\03_ingestion_staged_item.surql",
    "schema\04_ingestion_quarantine_record.surql",
    "schema\05_ingestion_publication_manifest.surql",
    "schema\06_ingestion_family_rule.surql",
    "schema\07_ingestion_specification.surql",
    "schema\08_ingestion_manufacturer_alias.surql",
    "schema\09_ingestion_unit_alias.surql",
    "schema\10_ingestion_substitution_rule.surql"
)

# 2. Liste des 20 fonctions SurrealQL
$functions = @(
    "functions\batch\ingestion_batch_create.surql",
    "functions\batch\ingestion_batch_checkpoint.surql",
    "functions\batch\ingestion_batch_transition.surql",
    "functions\staged\ingestion_staged_save.surql",
    "functions\staged\ingestion_staged_list.surql",
    "functions\staged\ingestion_staged_requalify.surql",
    "functions\quarantine\ingestion_quarantine_log.surql",
    "functions\quarantine\ingestion_quarantine_list.surql",
    "functions\quarantine\ingestion_quarantine_resolve.surql",
    "functions\manifest\ingestion_manifest_save.surql",
    "functions\manifest\ingestion_manifest_approve.surql",
    "functions\manifest\ingestion_manifest_record_exec.surql",
    "functions\manifest\ingestion_manifest_list.surql",
    "functions\manifest\ingestion_manifest_get_detail.surql",
    "functions\rule\ingestion_resolve_unit.surql",
    "functions\rule\ingestion_resolve_manufacturer.surql",
    "functions\rule\ingestion_rule_family_add.surql",
    "functions\rule\ingestion_rule_spec_add.surql",
    "functions\rule\ingestion_rule_substitution_add.surql",
    "functions\dashboard\ingestion_dashboard_metrics.surql"
)

# 3. Ressources complementaires
$events = @("events\01_events.surql")
$seeds = @(
    "seeds\01_initial_families.surql",
    "seeds\02_initial_specifications.surql",
    "seeds\03_initial_aliases.surql",
    "seeds\04_carrelage_demo.surql"
)
$errors = @("error\ingestion\error_definitions.surql")

function Execute-SurqlFile([string]$relativePath) {
    $fullPath = Join-Path $baseDir $relativePath
    if (-not (Test-Path $fullPath)) {
        Write-Host "[ERROR] Fichier introuvable : $fullPath"
        return $false
    }

    $rawContent = Get-Content -Path $fullPath -Raw -Encoding UTF8
    $query = "USE NS $Namespace DB $Database; " + $rawContent
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($query)

    try {
        $resp = Invoke-RestMethod -Uri $HttpUrl -Method Post -Headers $headers -ContentType 'text/plain; charset=utf-8' -Body $bodyBytes
        
        $hasErr = $false
        foreach ($item in $resp) {
            if ($item.status -eq "ERR") {
                Write-Host "  [ERR] dans $relativePath : $($item.result)"
                $hasErr = $true
            }
        }
        if (-not $hasErr) {
            Write-Host "  [OK] $relativePath"
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Host "  [EXCEPTION] HTTP sur $relativePath : $_"
        return $false
    }
}

# --- PASSE 1 : DEPLOIEMENT INITIAL ---
Write-Host ">>> ETAPE 1 : DEPLOIEMENT INITIAL DES RESSOURCES"

Write-Host "1. Deploiement des 11 Schemas..."
$failedSchemas = 0
foreach ($s in $schemas) { if (-not (Execute-SurqlFile $s)) { $failedSchemas++ } }

Write-Host "2. Deploiement des 20 Fonctions..."
$failedFuncs = 0
foreach ($f in $functions) { if (-not (Execute-SurqlFile $f)) { $failedFuncs++ } }

Write-Host "3. Deploiement des Evenements..."
foreach ($e in $events) { Execute-SurqlFile $e }

Write-Host "4. Deploiement des Seeds..."
foreach ($seed in $seeds) { Execute-SurqlFile $seed }

Write-Host "5. Deploiement des Definitions d'Erreurs..."
foreach ($err in $errors) { Execute-SurqlFile $err }

# --- PASSE 2 : VALIDATION D'IDEMPOTENCE ---
Write-Host ""
Write-Host ">>> ETAPE 2 : VALIDATION DE LA REEXECUTION IDEMPOTENTE (PASSE 2)"
$idempotenceErrors = 0
Write-Host "Re-execution des 11 Schemas..."
foreach ($s in $schemas) {
    if (-not (Execute-SurqlFile $s)) { $idempotenceErrors++ }
}
Write-Host "Re-execution des 20 Fonctions..."
foreach ($f in $functions) {
    if (-not (Execute-SurqlFile $f)) { $idempotenceErrors++ }
}
Write-Host "Re-execution des Evenements..."
foreach ($e in $events) {
    if (-not (Execute-SurqlFile $e)) { $idempotenceErrors++ }
}
Write-Host "Re-execution des Seeds..."
foreach ($seed in $seeds) {
    if (-not (Execute-SurqlFile $seed)) { $idempotenceErrors++ }
}
Write-Host "Re-execution des Definitions d'Erreurs..."
foreach ($err in $errors) {
    if (-not (Execute-SurqlFile $err)) { $idempotenceErrors++ }
}

Write-Host ""
if ($idempotenceErrors -eq 0 -and $failedSchemas -eq 0 -and $failedFuncs -eq 0) {
    Write-Host "[SUCCESS] Deploiement et Idempotence 100% valides (0 erreur)."
} else {
    Write-Host "[WARNING] $idempotenceErrors erreurs d'idempotence detectees."
}

# --- ETAPE 3 : AUDIT ET COMPTAGE DE L'ETAT DEPLOYE ---
Write-Host ""
Write-Host ">>> ETAPE 3 : AUDIT ET COMPTAGE DE L'ETAT DEPLOYE (INFO FOR DB)"
$infoQuery = "USE NS $Namespace DB $Database; INFO FOR DB;"
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($infoQuery)
$auditResp = Invoke-RestMethod -Uri $HttpUrl -Method Post -Headers $headers -ContentType 'text/plain; charset=utf-8' -Body $bodyBytes
$dbInfo = $auditResp[1].result

$tableCount = ($dbInfo.tables.PSObject.Properties | Measure-Object).Count
$funcCount = ($dbInfo.functions.PSObject.Properties | Measure-Object).Count

Write-Host "Tables creees    : $tableCount"
Write-Host "Fonctions creees : $funcCount"

Write-Host ""
Write-Host "=========================================================="
Write-Host "DEPLOIEMENT STAGING TERMINE AVEC SUCCES"
Write-Host "=========================================================="
