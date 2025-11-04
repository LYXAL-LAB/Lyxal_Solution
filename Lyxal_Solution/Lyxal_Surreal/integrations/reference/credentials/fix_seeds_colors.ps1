# =============================================================================================
# Script de Correction des Seeds Credentials
# Module : integrations > reference > credentials
# Description : Remplace les anciennes valeurs de couleurs en dur par des références theme_color_type
# Date : 2025-01-27
# =============================================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Correction des Seeds Credentials" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$totalFiles = 0
$totalReplacements = 0

# =============================================================================================
# Fonction : Remplacer dans un fichier avec regex
# =============================================================================================
function Replace-InFile {
    param(
        [string]$FilePath,
        [hashtable[]]$Patterns
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  [WARN] Fichier introuvable : $FilePath" -ForegroundColor Yellow
        return 0
    }
    
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    $replacements = 0
    
    foreach ($pattern in $Patterns) {
        $oldPattern = $pattern.Old
        $newPattern = $pattern.New
        
        # Utiliser regex pour remplacer
        $matches = ([regex]$oldPattern).Matches($content)
        if ($matches.Count -gt 0) {
            $content = $content -replace $oldPattern, $newPattern
            $replacements += $matches.Count
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  [OK] Corrige : $replacements remplacement(s)" -ForegroundColor Green
        return $replacements
    } else {
        Write-Host "  [INFO] Aucun changement necessaire" -ForegroundColor Gray
        return 0
    }
}

# =============================================================================================
# 1. CORRIGER auth_type_seeds.surql
# =============================================================================================
Write-Host "1. Correction de auth_type_seeds.surql..." -ForegroundColor Yellow
$authTypeFile = Join-Path $basePath "auth_type\auth_type_seeds.surql"

$authTypePatterns = @(
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "primary",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "primary",'
        New = '${1}color_type: theme_color_type:primary,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "success",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "success",'
        New = '${1}color_type: theme_color_type:success,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "warning",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "warning",'
        New = '${1}color_type: theme_color_type:warning,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "error",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "error",'
        New = '${1}color_type: theme_color_type:error,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "info",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "info",'
        New = '${1}color_type: theme_color_type:info,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "neutral",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "neutral",'
        New = '${1}color_type: theme_color_type:neutral,'
    }
)

$replaced = Replace-InFile -FilePath $authTypeFile -Patterns $authTypePatterns
$totalReplacements += $replaced
if ($replaced -gt 0) { $totalFiles++ }
Write-Host ""

# =============================================================================================
# 2. CORRIGER transmission_method_seeds.surql
# =============================================================================================
Write-Host "2. Correction de transmission_method_seeds.surql..." -ForegroundColor Yellow
$transmissionFile = Join-Path $basePath "transmission_method\transmission_method_seeds.surql"

$transmissionPatterns = @(
    @{ Old = '(?m)^(\s+)color_daisy: "success",'; New = '${1}color_type: theme_color_type:success,' },
    @{ Old = '(?m)^(\s+)color_daisy: "warning",'; New = '${1}color_type: theme_color_type:warning,' },
    @{ Old = '(?m)^(\s+)color_daisy: "error",'; New = '${1}color_type: theme_color_type:error,' },
    @{ Old = '(?m)^(\s+)color_daisy: "info",'; New = '${1}color_type: theme_color_type:info,' },
    @{ Old = '(?m)^(\s+)color_daisy: "neutral",'; New = '${1}color_type: theme_color_type:neutral,' },
    @{ Old = '(?m)^(\s+)color_daisy: "primary",'; New = '${1}color_type: theme_color_type:primary,' }
)

$replaced = Replace-InFile -FilePath $transmissionFile -Patterns $transmissionPatterns
$totalReplacements += $replaced
if ($replaced -gt 0) { $totalFiles++ }
Write-Host ""

# =============================================================================================
# 3. CORRIGER uses_credential_batch*.surql (14 fichiers)
# =============================================================================================
Write-Host "3. Correction des fichiers uses_credential_batch*.surql..." -ForegroundColor Yellow
$usesCredentialPath = Join-Path $basePath "uses_credentials"
$batchFiles = Get-ChildItem -Path $usesCredentialPath -Filter "uses_credential_batch*.surql"

$usesCredentialPatterns = @(
    # Format compact (une ligne) : badge_color:"primary"
    @{ Old = 'badge_color:"primary"'; New = 'badge_color_type: theme_color_type:primary' },
    @{ Old = 'badge_color:"success"'; New = 'badge_color_type: theme_color_type:success' },
    @{ Old = 'badge_color:"warning"'; New = 'badge_color_type: theme_color_type:warning' },
    @{ Old = 'badge_color:"error"'; New = 'badge_color_type: theme_color_type:error' },
    @{ Old = 'badge_color:"info"'; New = 'badge_color_type: theme_color_type:info' },
    @{ Old = 'badge_color:"neutral"'; New = 'badge_color_type: theme_color_type:neutral' },
    @{ Old = 'badge_color:"secondary"'; New = 'badge_color_type: theme_color_type:secondary' },
    @{ Old = 'badge_color:"accent"'; New = 'badge_color_type: theme_color_type:accent' },
    # Format multiligne : badge_color: "primary",
    @{ Old = '(?m)^(\s+)badge_color: "primary",'; New = '${1}badge_color_type: theme_color_type:primary,' },
    @{ Old = '(?m)^(\s+)badge_color: "success",'; New = '${1}badge_color_type: theme_color_type:success,' },
    @{ Old = '(?m)^(\s+)badge_color: "warning",'; New = '${1}badge_color_type: theme_color_type:warning,' },
    @{ Old = '(?m)^(\s+)badge_color: "error",'; New = '${1}badge_color_type: theme_color_type:error,' },
    @{ Old = '(?m)^(\s+)badge_color: "info",'; New = '${1}badge_color_type: theme_color_type:info,' },
    @{ Old = '(?m)^(\s+)badge_color: "neutral",'; New = '${1}badge_color_type: theme_color_type:neutral,' },
    @{ Old = '(?m)^(\s+)badge_color: "secondary",'; New = '${1}badge_color_type: theme_color_type:secondary,' },
    @{ Old = '(?m)^(\s+)badge_color: "accent",'; New = '${1}badge_color_type: theme_color_type:accent,' }
)

foreach ($file in $batchFiles) {
    Write-Host "  [FILE] $($file.Name)..." -ForegroundColor Cyan
    $replaced = Replace-InFile -FilePath $file.FullName -Patterns $usesCredentialPatterns
    $totalReplacements += $replaced
    if ($replaced -gt 0) { $totalFiles++ }
}
Write-Host ""

# =============================================================================================
# 4. CORRIGER credential_type_batch*.surql (36 fichiers)
# =============================================================================================
Write-Host "4. Correction des fichiers credential_type_batch*.surql..." -ForegroundColor Yellow
$credentialTypePath = Join-Path $basePath "credential_type"
$credentialBatchFiles = Get-ChildItem -Path $credentialTypePath -Filter "credential_type_batch*.surql"

$credentialTypePatterns = @(
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "primary",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "primary",'
        New = '${1}color_type: theme_color_type:primary,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "success",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "success",'
        New = '${1}color_type: theme_color_type:success,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "warning",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "warning",'
        New = '${1}color_type: theme_color_type:warning,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "error",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "error",'
        New = '${1}color_type: theme_color_type:error,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "info",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "info",'
        New = '${1}color_type: theme_color_type:info,'
    },
    # Pattern: color: "#XXXXXX",\r\n        color_daisy: "neutral",
    @{
        Old = '(?m)^(\s+)color: "#[0-9A-Fa-f]{6}",\r?\n\s+color_daisy: "neutral",'
        New = '${1}color_type: theme_color_type:neutral,'
    },
    # Pattern: Seulement color_daisy (sans color au-dessus)
    @{ Old = '(?m)^(\s+)color_daisy: "primary",'; New = '${1}color_type: theme_color_type:primary,' },
    @{ Old = '(?m)^(\s+)color_daisy: "success",'; New = '${1}color_type: theme_color_type:success,' },
    @{ Old = '(?m)^(\s+)color_daisy: "warning",'; New = '${1}color_type: theme_color_type:warning,' },
    @{ Old = '(?m)^(\s+)color_daisy: "error",'; New = '${1}color_type: theme_color_type:error,' },
    @{ Old = '(?m)^(\s+)color_daisy: "info",'; New = '${1}color_type: theme_color_type:info,' },
    @{ Old = '(?m)^(\s+)color_daisy: "neutral",'; New = '${1}color_type: theme_color_type:neutral,' }
)

foreach ($file in $credentialBatchFiles) {
    Write-Host "  [FILE] $($file.Name)..." -ForegroundColor Cyan
    $replaced = Replace-InFile -FilePath $file.FullName -Patterns $credentialTypePatterns
    $totalReplacements += $replaced
    if ($replaced -gt 0) { $totalFiles++ }
}
Write-Host ""

# =============================================================================================
# RÉSUMÉ
# =============================================================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Résumé" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fichiers modifiés : $totalFiles" -ForegroundColor Green
Write-Host "Total remplacements : $totalReplacements" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] Correction terminee !" -ForegroundColor Green
Write-Host ""
Write-Host "[IMPORTANT] Verifiez les fichiers modifies avant de les charger dans SurrealDB" -ForegroundColor Yellow
Write-Host ""
