# ============================================================================
# SCRIPT : Importation complète du système circular_menu
# Description : Importe le composant circular_menu et sa page de démonstration
# Usage : .\import_circular_menu_demo.ps1 [-Connection "http://localhost:8000"]
# ============================================================================

param(
    [string]$Connection = "http://localhost:8000",
    [string]$Namespace = "lyxal",
    [string]$Database = "studio"
)

Write-Host "🚀 Importation du système circular_menu" -ForegroundColor Green
Write-Host "Connexion: $Connection" -ForegroundColor Yellow
Write-Host "Namespace: $Namespace" -ForegroundColor Yellow
Write-Host "Database: $Database" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

# Fonction d'import sécurisé
function Import-File {
    param(
        [string]$File,
        [string]$Description
    )

    Write-Host "📦 Importation: $Description" -ForegroundColor Blue
    Write-Host "   Fichier: $File" -ForegroundColor Gray

    $command = "surreal import --conn $Connection --ns $Namespace --db $Database --file $File"
    $result = Invoke-Expression $command

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Succès" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Échec - Arrêt du script" -ForegroundColor Red
        Write-Host "   Commande: $command" -ForegroundColor Red
        Write-Host "   Erreur: $result" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# 1. Tags de base
Import-File -File "reference/studio/component/tags_base.surql" -Description "Tags de base pour les composants"

# 2. i18n pour le composant
Import-File -File "reference/studio/component/circular_menu_i18n_keys.surql" -Description "Clés i18n du composant circular_menu"
Import-File -File "reference/studio/component/circular_menu_i18n_translations.surql" -Description "Traductions i18n du composant circular_menu"

# 3. Composant circular_menu
Import-File -File "reference/studio/component/circular_menu.surql" -Description "Composant circular_menu"

# 4. i18n pour la page
Import-File -File "reference/studio/page/circular_menu_demo_i18n_keys.surql" -Description "Clés i18n de la page circular_menu_demo"
Import-File -File "reference/studio/page/circular_menu_demo_i18n_translations.surql" -Description "Traductions i18n de la page circular_menu_demo"

# 5. Page de démonstration
Import-File -File "reference/studio/page/circular_menu_demo.surql" -Description "Page de démonstration circular_menu_demo"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎉 Importation terminée avec succès !" -ForegroundColor Green
Write-Host ""
Write-Host "🧪 Tests de validation :" -ForegroundColor Magenta
Write-Host ""
Write-Host "# Vérifier le composant" -ForegroundColor Yellow
Write-Host "surreal sql --conn $Connection --ns $Namespace --db $Database --query 'SELECT * FROM studio_component:circular_menu;'" -ForegroundColor White
Write-Host ""
Write-Host "# Vérifier la page" -ForegroundColor Yellow
Write-Host "surreal sql --conn $Connection --ns $Namespace --db $Database --query 'SELECT * FROM studio_page:circular_menu_demo;'" -ForegroundColor White
Write-Host ""
Write-Host "# Tester l'accès à la page" -ForegroundColor Yellow
Write-Host "URL: /demo/circular-menu" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
