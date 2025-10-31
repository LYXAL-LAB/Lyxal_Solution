#!/usr/bin/env python3
"""
Script de nettoyage des tables temporaires générées par erreur
Supprime les modèles de requête/réponse qui ne devraient pas être des tables
"""

import os
from pathlib import Path

# Suffixes de tables à supprimer
SUFFIXES_TO_DELETE = [
    '_add_model.surql',
    '_update_model.surql',
    '_create_model.surql',
    '_request_model.surql',
    '_request.surql',
    '_response.surql',
    '_result.surql',
    '_result_model.surql',
    '_import_result_model.surql',
    '_settings_model.surql',
]

# Préfixes de tables à supprimer
PREFIXES_TO_DELETE = [
    'bunny_get_',
    'bunny_add_',
    'bunny_remove_',
    'bunny_update_',
    'bunny_create_',
    'bunny_delete_',
]

# Fichiers spécifiques à supprimer (pagination, etc.)
SPECIFIC_FILES_TO_DELETE = [
    'bunny_pagination_list_model_of_api_key_model.surql',
    'bunny_pagination_list_model_of_dns_zone_model.surql',
    'bunny_pagination_list_model_of_edge_script_model.surql',
    'bunny_pagination_list_model_of_edge_script_release_model.surql',
    'bunny_pagination_list_model_of_pull_zone_model.surql',
    'bunny_pagination_list_model_of_storage_zone_model.surql',
    'bunny_pagination_list_model_of_video_library_model.surql',
    'bunny_pagination_list_of_collection_model.surql',
    'bunny_pagination_list_of_video_model.surql',
    'bunny_pagination_response.surql',
    'bunny_accepted_result.surql',
    'bunny_unauthorized_result.surql',
    'bunny_problem_details.surql',
    'bunny_generic_request_response.surql',
]

# Tables à GARDER malgré les règles (exceptions)
KEEP_THESE_FILES = [
    'bunny_dns_zone_model.surql',  # Entité principale
    'bunny_pull_zone_model.surql',  # Entité principale
    'bunny_storage_zone_model.surql',  # Entité principale
    'bunny_video_library_model.surql',  # Entité principale
    'bunny_video_model.surql',  # Entité principale
    'bunny_collection_model.surql',  # Entité principale
    'bunny_edge_script_model.surql',  # Entité principale
    'bunny_api_key_model.surql',  # Entité principale
    # Tables créées manuellement
    'bunny_country.surql',
    'bunny_storage.surql',
    'bunny_cdn.surql',
    'bunny_containers.surql',
    'infrastructure_logs.surql',
]


def should_delete(filename: str) -> bool:
    """Détermine si un fichier doit être supprimé"""
    
    # Garder les fichiers de la whitelist
    if filename in KEEP_THESE_FILES:
        return False
    
    # Supprimer les fichiers spécifiques
    if filename in SPECIFIC_FILES_TO_DELETE:
        return True
    
    # Supprimer par suffixe
    for suffix in SUFFIXES_TO_DELETE:
        if filename.endswith(suffix):
            return True
    
    # Supprimer par préfixe
    for prefix in PREFIXES_TO_DELETE:
        if filename.startswith(prefix):
            return True
    
    return False


def clean_database_directory(database_path: Path, dry_run: bool = True):
    """Nettoie le dossier database/ des tables temporaires"""
    
    print("🧹 Nettoyage des tables temporaires")
    print(f"📁 Dossier: {database_path}")
    print(f"{'🔍 Mode DRY-RUN' if dry_run else '❌ MODE SUPPRESSION'}")
    print("=" * 80)
    
    files_to_delete = []
    files_to_keep = []
    
    # Scanner tous les fichiers .surql
    for file in database_path.glob('*.surql'):
        filename = file.name
        
        if should_delete(filename):
            files_to_delete.append(file)
        else:
            files_to_keep.append(file)
    
    # Afficher les résultats
    print(f"\n✅ Fichiers à GARDER : {len(files_to_keep)}")
    for file in sorted(files_to_keep):
        print(f"  ✅ {file.name}")
    
    print(f"\n❌ Fichiers à SUPPRIMER : {len(files_to_delete)}")
    for file in sorted(files_to_delete):
        print(f"  ❌ {file.name}")
    
    # Supprimer si pas en mode dry-run
    if not dry_run and files_to_delete:
        print("\n" + "=" * 80)
        response = input(f"⚠️  Confirmer la suppression de {len(files_to_delete)} fichiers ? (oui/non): ")
        
        if response.lower() in ['oui', 'yes', 'y', 'o']:
            deleted_count = 0
            for file in files_to_delete:
                try:
                    file.unlink()
                    deleted_count += 1
                    print(f"  🗑️  Supprimé: {file.name}")
                except Exception as e:
                    print(f"  ❌ Erreur: {file.name} - {e}")
            
            print(f"\n✅ {deleted_count} fichiers supprimés")
        else:
            print("\n❌ Annulé")
    
    print("\n" + "=" * 80)
    print("✅ Analyse terminée")
    
    return len(files_to_keep), len(files_to_delete)


if __name__ == "__main__":
    import sys
    
    # Déterminer le chemin de base
    script_dir = Path(__file__).parent
    database_path = script_dir / "database"
    
    # Vérifier si on a un argument --yes
    auto_confirm = '--yes' in sys.argv or '-y' in sys.argv
    
    print("🧹 Script de nettoyage des tables temporaires Bunny.net")
    print("=" * 80)
    print()
    print("Ce script va analyser et supprimer les tables qui représentent")
    print("des modèles temporaires (requêtes, réponses, pagination, etc.)")
    print()
    
    # D'abord en mode dry-run
    print("📋 ÉTAPE 1 : Analyse (dry-run)")
    print("-" * 80)
    keep_count, delete_count = clean_database_directory(database_path, dry_run=True)
    
    print()
    print(f"📊 Résumé :")
    print(f"  - Tables à garder : {keep_count}")
    print(f"  - Tables à supprimer : {delete_count}")
    print()
    
    if delete_count > 0:
        if auto_confirm:
            response = 'oui'
            print("💡 Confirmation automatique activée (--yes)")
        else:
            response = input("💡 Voulez-vous exécuter la suppression ? (oui/non): ")
        
        if response.lower() in ['oui', 'yes', 'y', 'o']:
            print()
            print("📋 ÉTAPE 2 : Suppression")
            print("-" * 80)
            
            # Suppression directe sans demander confirmation
            files_to_delete = []
            for file in database_path.glob('*.surql'):
                if should_delete(file.name):
                    files_to_delete.append(file)
            
            deleted_count = 0
            for file in files_to_delete:
                try:
                    file.unlink()
                    deleted_count += 1
                    print(f"  🗑️  Supprimé: {file.name}")
                except Exception as e:
                    print(f"  ❌ Erreur: {file.name} - {e}")
            
            print(f"\n✅ {deleted_count} fichiers supprimés avec succès")
        else:
            print("\n✅ Aucune modification effectuée")
    else:
        print("✅ Aucune table à supprimer")

