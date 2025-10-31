# =============================================================================================
# SCRIPT D'IMPORT COMPLET - MODULE INTEGRATIONS
# Importe tous les seeds dans SurrealDB dans le bon ordre
# =============================================================================================

param(
    [string]$SurrealHost = "http://localhost:8000",
    [string]$Username = "root",
    [string]$Password = "root",
    [string]$Namespace = "lyxal",
    [string]$Database = "main"
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Compteurs
$TotalFiles = 0
$SuccessCount = 0
$ErrorCount = 0
$StartTime = Get-Date

# =============================================================================================
# FONCTIONS
# =============================================================================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Text.PadRight(70)) ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host "▶ $Text" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ✅ $Text" -ForegroundColor Green
    $script:SuccessCount++
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "  ❌ $Text" -ForegroundColor Red
    $script:ErrorCount++
}

function Import-SurqlFile {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    $script:TotalFiles++
    
    if (-not (Test-Path $FilePath)) {
        Write-Error-Custom "$Description - Fichier introuvable: $FilePath"
        return $false
    }
    
    try {
        Write-Host "  📄 $Description..." -NoNewline
        
        # Import avec surreal CLI
        $result = surreal import --conn $SurrealHost --user $Username --pass $Password --ns $Namespace --db $Database $FilePath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
            $script:SuccessCount++
            return $true
        } else {
            Write-Host " ❌" -ForegroundColor Red
            Write-Host "    Erreur: $result" -ForegroundColor Red
            $script:ErrorCount++
            return $false
        }
    }
    catch {
        Write-Host " ❌" -ForegroundColor Red
        Write-Host "    Exception: $($_.Exception.Message)" -ForegroundColor Red
        $script:ErrorCount++
        return $false
    }
}

function Import-Batch {
    param(
        [string]$BasePath,
        [string]$TableName,
        [int]$BatchCount,
        [string]$FilePattern
    )
    
    Write-Step "Import de $TableName ($BatchCount batches)"
    
    for ($i = 1; $i -le $BatchCount; $i++) {
        $fileName = $FilePattern -replace '\{BATCH\}', $i
        $filePath = Join-Path $BasePath $fileName
        Import-SurqlFile -FilePath $filePath -Description "Batch $i/$BatchCount"
    }
}

# =============================================================================================
# VÉRIFICATIONS PRÉLIMINAIRES
# =============================================================================================

Write-Header "VÉRIFICATIONS PRÉLIMINAIRES"

Write-Step "Vérification de SurrealDB CLI"
try {
    $surrealVersion = surreal version 2>&1
    Write-Success "SurrealDB CLI détecté: $($surrealVersion -split "`n" | Select-Object -First 1)"
}
catch {
    Write-Error-Custom "SurrealDB CLI non trouvé. Installez-le : https://surrealdb.com/install"
    exit 1
}

Write-Step "Vérification de la connexion à $SurrealHost"
try {
    # Test simple de connexion (à adapter selon votre setup)
    Write-Success "Connexion OK (assumée)"
}
catch {
    Write-Error-Custom "Impossible de se connecter à $SurrealHost"
    exit 1
}

# =============================================================================================
# ORDRE D'IMPORT
# =============================================================================================
# IMPORTANT: Respecter l'ordre des dépendances !
# 1. Tables de base (language, i18n_key, logo_brand, url, icon)
# 2. Relations i18n (i18n_translation)
# 3. Provider
# 4. Credential_type & auth_type
# 5. Service
# 6. Uses_credential (relation)
# 7. Resource
# 8. Tool
# =============================================================================================

Write-Header "IMPORT DES SEEDS - MODULE INTEGRATIONS"

$BaseDir = $PSScriptRoot

# =============================================================================================
# 1. TABLES DE BASE (à créer manuellement si nécessaire)
# =============================================================================================

Write-Header "ÉTAPE 1/8 - TABLES DE BASE"
Write-Host "ℹ️  Assurez-vous que les tables de base existent:" -ForegroundColor Cyan
Write-Host "   • language (FR, EN, IT, DE, ES)" -ForegroundColor Gray
Write-Host "   • i18n_key" -ForegroundColor Gray
Write-Host "   • logo_brand" -ForegroundColor Gray
Write-Host "   • url" -ForegroundColor Gray
Write-Host "   • icon`n" -ForegroundColor Gray
Write-Host "Appuyez sur ENTRÉE pour continuer..." -ForegroundColor Yellow
Read-Host

# =============================================================================================
# 2. CREDENTIAL_TYPE (36 batches)
# =============================================================================================

Write-Header "ÉTAPE 2/8 - CREDENTIAL_TYPE (419 seeds)"

$credPath = Join-Path $BaseDir "reference\credentials\credential_type"

# Seeds
Import-Batch -BasePath $credPath -TableName "credential_type seeds" -BatchCount 36 -FilePattern "credential_type_batch{BATCH}_seeds.surql"

# i18n keys
Import-Batch -BasePath $credPath -TableName "credential_type i18n_keys" -BatchCount 36 -FilePattern "credential_type_batch{BATCH}_i18n_keys.surql"

# i18n translations
Import-Batch -BasePath $credPath -TableName "credential_type i18n_translations" -BatchCount 36 -FilePattern "credential_type_batch{BATCH}_i18n_translations.surql"

# =============================================================================================
# 3. PROVIDER (9 batches)
# =============================================================================================

Write-Header "ÉTAPE 3/8 - PROVIDER (266 seeds)"

$providerPath = Join-Path $BaseDir "reference\Provider"

# Seeds
Import-Batch -BasePath $providerPath -TableName "provider seeds" -BatchCount 9 -FilePattern "provider_batch{BATCH}_seeds.surql"

# i18n keys
Import-Batch -BasePath $providerPath -TableName "provider i18n_keys" -BatchCount 9 -FilePattern "provider_batch{BATCH}_i18n_keys.surql"

# i18n translations
Import-Batch -BasePath $providerPath -TableName "provider i18n_translations" -BatchCount 9 -FilePattern "provider_batch{BATCH}_i18n_translations.surql"

# =============================================================================================
# 4. SERVICE (21 batches)
# =============================================================================================

Write-Header "ÉTAPE 4/8 - SERVICE (419 seeds)"

$servicePath = Join-Path $BaseDir "reference\service"

# Seeds
Import-Batch -BasePath $servicePath -TableName "service seeds" -BatchCount 21 -FilePattern "service_batch{BATCH}_seeds.surql"

# i18n keys
Import-Batch -BasePath $servicePath -TableName "service i18n_keys" -BatchCount 21 -FilePattern "service_batch{BATCH}_i18n_keys.surql"

# i18n translations
Import-Batch -BasePath $servicePath -TableName "service i18n_translations" -BatchCount 21 -FilePattern "service_batch{BATCH}_i18n_translations.surql"

# =============================================================================================
# 5. USES_CREDENTIAL (14 batches)
# =============================================================================================

Write-Header "ÉTAPE 5/8 - USES_CREDENTIAL (419 relations)"

$usesCredPath = Join-Path $BaseDir "reference\credentials\uses_credentials"

# Seeds
Import-Batch -BasePath $usesCredPath -TableName "uses_credential seeds" -BatchCount 14 -FilePattern "uses_credential_batch{BATCH}_seeds.surql"

# i18n keys (1 seul fichier)
Import-SurqlFile -FilePath (Join-Path $usesCredPath "uses_credential_i18n_keys.surql") -Description "uses_credential i18n_keys"

# i18n translations (1 seul fichier)
Import-SurqlFile -FilePath (Join-Path $usesCredPath "uses_credential_i18n_translations.surql") -Description "uses_credential i18n_translations"

# =============================================================================================
# 6. RESOURCE (22 batches)
# =============================================================================================

Write-Header "ÉTAPE 6/8 - RESOURCE (1,091 seeds)"

$resourcePath = Join-Path $BaseDir "reference\resource"

# Seeds
Import-Batch -BasePath $resourcePath -TableName "resource seeds" -BatchCount 22 -FilePattern "resource_batch{BATCH}_seeds.surql"

# i18n keys
Import-Batch -BasePath $resourcePath -TableName "resource i18n_keys" -BatchCount 22 -FilePattern "resource_batch{BATCH}_i18n_keys.surql"

# i18n translations
Import-Batch -BasePath $resourcePath -TableName "resource i18n_translations" -BatchCount 22 -FilePattern "resource_batch{BATCH}_i18n_translations.surql"

# =============================================================================================
# 7. TOOL (25 batches)
# =============================================================================================

Write-Header "ÉTAPE 7/8 - TOOL (2,436 seeds)"

$toolPath = Join-Path $BaseDir "reference\tool"

# Seeds
Import-Batch -BasePath $toolPath -TableName "tool seeds" -BatchCount 25 -FilePattern "tool_batch{BATCH}_seeds.surql"

# i18n keys
Import-Batch -BasePath $toolPath -TableName "tool i18n_keys" -BatchCount 25 -FilePattern "tool_batch{BATCH}_i18n_keys.surql"

# i18n translations
Import-Batch -BasePath $toolPath -TableName "tool i18n_translations" -BatchCount 25 -FilePattern "tool_batch{BATCH}_i18n_translations.surql"

# =============================================================================================
# 8. RÉCAPITULATIF FINAL
# =============================================================================================

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Header "IMPORT TERMINÉ !"

Write-Host "📊 STATISTIQUES:`n" -ForegroundColor Yellow
Write-Host "   • Fichiers traités : $TotalFiles" -ForegroundColor White
Write-Host "   • Succès : $SuccessCount ✅" -ForegroundColor Green
Write-Host "   • Erreurs : $ErrorCount ❌" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host "   • Durée totale : $($Duration.ToString('mm\:ss'))`n" -ForegroundColor White

if ($ErrorCount -eq 0) {
    Write-Host "🎉 IMPORT RÉUSSI - TOUTES LES DONNÉES SONT EN BASE !" -ForegroundColor Green
} else {
    Write-Host "⚠️  IMPORT TERMINÉ AVEC ERREURS - Vérifiez les logs ci-dessus" -ForegroundColor Yellow
}

Write-Host ""

