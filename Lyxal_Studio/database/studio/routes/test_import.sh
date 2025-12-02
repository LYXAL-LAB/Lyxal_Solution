#!/bin/bash

# Script de test pour l'importation des schémas de routes dynamiques
# Utilise les variables d'environnement pour la connexion

set -e

echo "🚀 Test d'importation des schémas de routes dynamiques"

# Variables de connexion (à adapter selon votre environnement)
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"8000"}
DB_USER=${DB_USER:-"root"}
DB_PASS=${DB_PASS:-"root"}
DB_NS=${DB_NS:-"lyxal"}
DB_DB=${DB_DB:-"studio"}

echo "📡 Connexion à SurrealDB: ${DB_HOST}:${DB_PORT}"
echo "🗄️  Namespace: ${DB_NS}, Database: ${DB_DB}"

# Fonction d'import
import_file() {
    local file=$1
    local description=$2

    echo "📄 Importation: ${description}"
    echo "   Fichier: ${file}"

    if surreal import \
        --conn "http://${DB_HOST}:${DB_PORT}" \
        --user "${DB_USER}" \
        --pass "${DB_PASS}" \
        --ns "${DB_NS}" \
        --db "${DB_DB}" \
        "${file}"; then
        echo "✅ ${description} - SUCCÈS"
    else
        echo "❌ ${description} - ÉCHEC"
        exit 1
    fi
}

# Import des schémas
echo ""
echo "🏗️  Importation des schémas..."
import_file "studio_route.surql" "Schéma studio_route"
import_file "route_permissions.surql" "Schéma route_permissions"
import_file "route_guards.surql" "Schéma route_guards"

# Import des données de référence
echo ""
echo "📦 Importation des données de référence..."
import_file "../reference/studio/routes/route_permissions_seeds.surql" "Permissions de base"
import_file "../reference/studio/routes/route_guards_seeds.surql" "Guards de base"

# Import des routes d'exemple
echo ""
echo "🛣️  Importation des routes d'exemple..."
import_file "../reference/studio/routes/route_seeds.surql" "Routes d'exemple"

echo ""
echo "🎉 Importation terminée avec succès !"

# Vérification des données
echo ""
echo "🔍 Vérification des données importées..."

# Compter les routes
route_count=$(surreal query \
    --conn "http://${DB_HOST}:${DB_PORT}" \
    --user "${DB_USER}" \
    --pass "${DB_PASS}" \
    --ns "${DB_NS}" \
    --db "${DB_DB}" \
    "SELECT count() FROM studio_route GROUP ALL" | jq -r '.[0].count')

echo "📊 Routes créées: ${route_count}"

# Compter les permissions
perm_count=$(surreal query \
    --conn "http://${DB_HOST}:${DB_PORT}" \
    --user "${DB_USER}" \
    --pass "${DB_PASS}" \
    --ns "${DB_NS}" \
    --db "${DB_DB}" \
    "SELECT count() FROM route_permissions GROUP ALL" | jq -r '.[0].count')

echo "🔐 Permissions créées: ${perm_count}"

# Compter les guards
guard_count=$(surreal query \
    --conn "http://${DB_HOST}:${DB_PORT}" \
    --user "${DB_USER}" \
    --pass "${DB_PASS}" \
    --ns "${DB_NS}" \
    --db "${DB_DB}" \
    "SELECT count() FROM route_guards GROUP ALL" | jq -r '.[0].count')

echo "🛡️  Guards créés: ${guard_count}"

echo ""
echo "✅ Test d'importation réussi !"
echo "🎯 Base de données prête pour les routes dynamiques."
