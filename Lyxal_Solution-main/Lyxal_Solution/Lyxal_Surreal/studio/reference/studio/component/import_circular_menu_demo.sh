#!/bin/bash

# ============================================================================
# SCRIPT : Importation complète du système circular_menu
# Description : Importe le composant circular_menu et sa page de démonstration
# Usage : ./import_circular_menu_demo.sh [connection_string]
# Exemple : ./import_circular_menu_demo.sh "http://localhost:8000"
# ============================================================================

# Configuration par défaut
CONNECTION="${1:-http://localhost:8000}"
NAMESPACE="lyxal"
DATABASE="studio"

echo "🚀 Importation du système circular_menu"
echo "Connexion: $CONNECTION"
echo "Namespace: $NAMESPACE"
echo "Database: $DATABASE"
echo "========================================"

# Fonction d'import sécurisé
import_file() {
    local file="$1"
    local description="$2"

    echo "📦 Importation: $description"
    echo "   Fichier: $file"

    if surreal import --conn "$CONNECTION" --ns "$NAMESPACE" --db "$DATABASE" --file "$file"; then
        echo "   ✅ Succès"
    else
        echo "   ❌ Échec - Arrêt du script"
        exit 1
    fi
    echo ""
}

# 1. Schéma de base (vérifier s'ils existent déjà)
echo "🔍 Vérification des schémas de base..."

# 2. Tags de base
import_file "reference/studio/component/tags_base.surql" "Tags de base pour les composants"

# 3. i18n pour le composant
import_file "reference/studio/component/circular_menu_i18n_keys.surql" "Clés i18n du composant circular_menu"
import_file "reference/studio/component/circular_menu_i18n_translations.surql" "Traductions i18n du composant circular_menu"

# 4. Composant circular_menu
import_file "reference/studio/component/circular_menu.surql" "Composant circular_menu"

# 5. i18n pour la page
import_file "reference/studio/page/circular_menu_demo_i18n_keys.surql" "Clés i18n de la page circular_menu_demo"
import_file "reference/studio/page/circular_menu_demo_i18n_translations.surql" "Traductions i18n de la page circular_menu_demo"

# 6. Page de démonstration
import_file "reference/studio/page/circular_menu_demo.surql" "Page de démonstration circular_menu_demo"

echo "========================================"
echo "🎉 Importation terminée avec succès !"
echo ""
echo "🧪 Tests de validation :"
echo ""
echo "# Vérifier le composant"
echo "surreal sql --conn $CONNECTION --ns $NAMESPACE --db $DATABASE --query 'SELECT * FROM studio_component:circular_menu;'"
echo ""
echo "# Vérifier la page"
echo "surreal sql --conn $CONNECTION --ns $NAMESPACE --db $DATABASE --query 'SELECT * FROM studio_page:circular_menu_demo;'"
echo ""
echo "# Tester l'accès à la page"
echo "URL: /demo/circular-menu"
echo ""
echo "========================================"
