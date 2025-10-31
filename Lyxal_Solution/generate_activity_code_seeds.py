#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds pour la table business_activity_code
à partir des données extraites avec hiérarchie complète
"""

import json
from pathlib import Path

def sanitize_id(code):
    """Convertit un code en ID valide pour SurrealDB"""
    # Remplacer les caractères spéciaux
    id_code = code.replace('.', '_')
    id_code = id_code.replace(' ', '_')
    id_code = id_code.replace('-', '_')
    id_code = id_code.lower()
    return id_code

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    # Échapper les apostrophes
    s = s.replace("'", "\\'")
    return s

def generate_activity_seeds():
    input_file = Path("nomenclatures_hierarchical/nomenclatures_hierarchical_complete.json")
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_file = output_dir / "business_activity_code_seeds.surql"
    
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS POUR business_activity_code")
    print("=" * 100)
    print()
    print(f"📁 Lecture: {input_file}")
    
    if not input_file.exists():
        print(f"❌ Fichier introuvable: {input_file}")
        return
    
    with open(input_file, 'r', encoding='utf-8') as f:
        codes = json.load(f)
    
    print(f"✅ {len(codes):,} codes chargés")
    print()
    print(f"📝 Génération du fichier SQL...")
    
    # Mapping des nomenclatures vers les IDs
    nomenclature_map = {
        'NAFRev2': 'business_nomenclature_type:nafrev2',
        'NAFRev1': 'business_nomenclature_type:nafrev1',
        'NAF1993': 'business_nomenclature_type:naf1993',
        'NAP': 'business_nomenclature_type:nap'
    }
    
    # Mapping des niveaux vers les IDs
    level_map = {
        'section': 'business_hierarchical_level:section',
        'division': 'business_hierarchical_level:division',
        'groupe': 'business_hierarchical_level:groupe',
        'classe': 'business_hierarchical_level:classe',
        'sous_classe': 'business_hierarchical_level:sous_classe'
    }
    
    # Créer un index des codes pour résoudre les parents
    code_index = {}
    for code_data in codes:
        key = f"{code_data['nomenclature']}:{code_data['code']}"
        code_index[key] = code_data
    
    # Générer le fichier SQL
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_activity_code\n")
        f.write("-- Description: Codes d'activités économiques (hiérarchie complète)\n")
        f.write(f"-- Total: {len(codes):,} codes\n")
        f.write("-- " + "=" * 97 + "\n")
        f.write("\n")
        
        # Grouper par nomenclature
        from collections import defaultdict
        by_nomenclature = defaultdict(list)
        
        for code_data in codes:
            by_nomenclature[code_data['nomenclature']].append(code_data)
        
        # Générer les INSERT par nomenclature
        for nomenclature in ['NAFRev2', 'NAFRev1', 'NAF1993', 'NAP']:
            if nomenclature not in by_nomenclature:
                continue
            
            codes_list = by_nomenclature[nomenclature]
            
            f.write("-- " + "-" * 97 + "\n")
            f.write(f"-- {nomenclature} ({len(codes_list):,} codes)\n")
            f.write("-- " + "-" * 97 + "\n")
            f.write("\n")
            
            # Trier par niveau (section -> division -> groupe -> classe -> sous-classe)
            level_order = ['section', 'division', 'groupe', 'classe', 'sous_classe']
            codes_list.sort(key=lambda x: (
                level_order.index(x['niveau']) if x['niveau'] in level_order else 999,
                x['code']
            ))
            
            for code_data in codes_list:
                code = code_data['code']
                level = code_data['niveau']
                parent = code_data.get('parent_code')
                
                # Générer l'ID
                record_id = f"{nomenclature.lower()}_{sanitize_id(code)}"
                
                # Échapper les libellés
                libelle_long = escape_string(code_data.get('libelle_long', ''))
                libelle_moyen = escape_string(code_data.get('libelle_moyen', ''))
                libelle_court = escape_string(code_data.get('libelle_court', ''))
                
                # Trouver l'ID du parent
                parent_id = "NONE"
                if parent:
                    parent_key = f"{nomenclature}:{parent}"
                    if parent_key in code_index:
                        parent_id = f"business_activity_code:{nomenclature.lower()}_{sanitize_id(parent)}"
                
                f.write(f"CREATE business_activity_code:{record_id} SET\n")
                f.write(f"    code = '{code}',\n")
                f.write(f"    nomenclature_type = {nomenclature_map[nomenclature]},\n")
                f.write(f"    hierarchical_level = {level_map[level]},\n")
                f.write(f"    parent_code = {parent_id},\n")
                f.write(f"    libelle_long = '{libelle_long}',\n")
                f.write(f"    libelle_moyen = '{libelle_moyen}',\n")
                f.write(f"    libelle_court = '{libelle_court}';\n")
                f.write("\n")
            
            f.write("\n")
    
    print(f"✅ Fichier généré: {output_file}")
    print()
    
    # Statistiques
    print("=" * 100)
    print("📊 STATISTIQUES")
    print("=" * 100)
    print()
    
    for nomenclature in ['NAFRev2', 'NAFRev1', 'NAF1993', 'NAP']:
        if nomenclature in by_nomenclature:
            codes_list = by_nomenclature[nomenclature]
            print(f"{nomenclature:15s}: {len(codes_list):5,} codes")
    
    print()
    print(f"TOTAL:            {len(codes):5,} codes")
    print()
    print("=" * 100)
    print()
    print("✅ Seeds générés avec succès !")
    print()
    print("📋 Fichiers créés:")
    print(f"   1. {output_dir / 'business_nomenclature_type.surql'}")
    print(f"   2. {output_dir / 'business_nomenclature_type_seeds.surql'}")
    print(f"   3. {output_dir / 'business_hierarchical_level.surql'}")
    print(f"   4. {output_dir / 'business_hierarchical_level_seeds.surql'}")
    print(f"   5. {output_dir / 'business_activity_code.surql'}")
    print(f"   6. {output_dir / 'business_activity_code_seeds.surql'} ⬅️ NOUVEAU")
    print()
    print("=" * 100)

if __name__ == "__main__":
    generate_activity_seeds()

