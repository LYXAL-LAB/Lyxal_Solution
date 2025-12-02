# Script de test pour l'importation des schémas de routes dynamiques
# Version PowerShell pour Windows

param(
    [string]$DB_HOST = "localhost",
    [string]$DB_PORT = "8000",
    [string]$DB_USER = "root",
    [string]$DB_PASS = "root",
    [string]$DB_NS = "lyxal",
    [string]$DB_DB = "studio"
)

Write-Host "🚀 Test d'importation des schémas de routes dynamiques" -ForegroundColor Green
Write-Host "📡 Connexion à SurrealDB: ${DB_HOST}:${DB_PORT}" -ForegroundColor Blue
Write-Host "🗄️  Namespace: ${DB_NS}, Database: ${DB_DB}" -ForegroundColor Blue
Write-Host ""

# Fonction d'import
function Import-SurrealFile {
    param(
        [string]$FilePath,
        [string]$Description
    )

    Write-Host "📄 Importation: ${Description}" -ForegroundColor Yellow
    Write-Host "   Fichier: ${FilePath}" -ForegroundColor Gray

    try {
        $result = surreal import `
            --conn "http://${DB_HOST}:${DB_PORT}" `
            --user "${DB_USER}" `
            --pass "${DB_PASS}" `
            --ns "${DB_NS}" `
            --db "${DB_DB}" `
            "${FilePath}"

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ ${Description} - SUCCÈS" -ForegroundColor Green
        } else {
            Write-Host "❌ ${Description} - ÉCHEC" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "❌ ${Description} - ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Fonction de requête
function Query-Surreal {
    param([string]$Query)

    try {
        $result = surreal query `
            --conn "http://${DB_HOST}:${DB_PORT}" `
            --user "${DB_USER}" `
            --pass "${DB_PASS}" `
            --ns "${DB_NS}" `
            --db "${DB_DB}" `
            "${Query}"

        return $result
    }
    catch {
        Write-Host "❌ Erreur de requête: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Import des schémas
Write-Host "🏗️  Importation des schémas..." -ForegroundColor Cyan
Import-SurrealFile "studio_route.surql" "Schéma studio_route"
Import-SurrealFile "route_permissions.surql" "Schéma route_permissions"
Import-SurrealFile "route_guards.surql" "Schéma route_guards"

# Import des données de référence
Write-Host ""
Write-Host "📦 Importation des données de référence..." -ForegroundColor Cyan
Import-SurrealFile "../reference/studio/routes/route_permissions_seeds.surql" "Permissions de base"
Import-SurrealFile "../reference/studio/routes/route_guards_seeds.surql" "Guards de base"

# Import des routes d'exemple
Write-Host ""
Write-Host "🛣️  Importation des routes d'exemple..." -ForegroundColor Cyan
Import-SurrealFile "../reference/studio/routes/route_seeds.surql" "Routes d'exemple"

Write-Host ""
Write-Host "🎉 Importation terminée avec succès !" -ForegroundColor Green

# Vérification des données
Write-Host ""
Write-Host "🔍 Vérification des données importées..." -ForegroundColor Cyan

# Compter les routes
$routeQuery = Query-Surreal "SELECT count() FROM studio_route GROUP ALL"
if ($routeQuery) {
    $routeCount = ($routeQuery | ConvertFrom-Json)[0].count
    Write-Host "📊 Routes créées: ${routeCount}" -ForegroundColor White
}

# Compter les permissions
$permQuery = Query-Surreal "SELECT count() FROM route_permissions GROUP ALL"
if ($permQuery) {
    $permCount = ($permQuery | ConvertFrom-Json)[0].count
    Write-Host "🔐 Permissions créées: ${permCount}" -ForegroundColor White
}

# Compter les guards
$guardQuery = Query-Surreal "SELECT count() FROM route_guards GROUP ALL"
if ($guardQuery) {
    $guardCount = ($guardQuery | ConvertFrom-Json)[0].count
    Write-Host "🛡️  Guards créés: ${guardCount}" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Test d'importation réussi !" -ForegroundColor Green
Write-Host "🎯 Base de données prête pour les routes dynamiques." -ForegroundColor Green
