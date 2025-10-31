#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds pour business_activity_code avec i18n
Note: Pour cette version initiale, on utilise le libellé français pour toutes les langues
"""

import json
from pathlib import Path

# Les 5 langues actives
ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def sanitize_id(code):
    """Convertit un code en ID valide pour SurrealDB"""
    id_code = code.replace('.', '_')
    id_code = id_code.replace(' ', '_')
    id_code = id_code.replace('-', '_')
    id_code = id_code.lower()
    return id_code

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    s = s.replace("'", "\\'")
    return s

def generate_activity_code_i18n_seeds():
    input_file = Path("nomenclatures_hierarchical/nomenclatures_hierarchical_complete.json")
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS I18N POUR business_activity_code")
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
    
    # Fichiers de sortie
    i18n_keys_file = output_dir / "business_activity_code_i18n_keys.surql"
    i18n_trans_file = output_dir / "business_activity_code_i18n_translations.surql"
    seeds_file = output_dir / "business_activity_code_seeds.surql"
    
    print("📝 Génération des fichiers...")
    print()
    
    # 1. Générer les i18n keys
    print("1️⃣  I18N Keys...")
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_activity_code\n")
        f.write(f"-- Total: {len(codes):,} codes × 3 libellés = {len(codes) * 3:,} keys\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for code_data in codes:
            nomenclature = code_data['nomenclature'].lower()
            code = sanitize_id(code_data['code'])
            record_id = f"{nomenclature}_{code}"
            
            # Key pour libellé long
            key_long = f"i18n_activity_code_{record_id}_long"
            f.write(f"CREATE i18n_key:{key_long} SET\n")
            f.write(f"    description = 'Libellé long pour {code_data['nomenclature']}: {code_data['code']}';\n\n")
            
            # Key pour libellé moyen (si existe)
            if code_data.get('libelle_moyen'):
                key_moyen = f"i18n_activity_code_{record_id}_moyen"
                f.write(f"CREATE i18n_key:{key_moyen} SET\n")
                f.write(f"    description = 'Libellé moyen pour {code_data['nomenclature']}: {code_data['code']}';\n\n")
            
            # Key pour libellé court (si existe)
            if code_data.get('libelle_court'):
                key_court = f"i18n_activity_code_{record_id}_court"
                f.write(f"CREATE i18n_key:{key_court} SET\n")
                f.write(f"    description = 'Libellé court pour {code_data['nomenclature']}: {code_data['code']}';\n\n")
    
    print(f"   ✅ {len(codes) * 3:,} i18n keys générées")
    print()
    
    # 2. Générer les traductions
    print("2️⃣  I18N Translations (ce fichier sera TRÈS gros)...")
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_activity_code\n")
        f.write(f"-- Total: {len(codes):,} codes × 3 libellés × 5 langues = {len(codes) * 3 * 5:,} traductions\n")
        f.write("-- Note: Pour cette version initiale, les libellés français sont utilisés pour toutes les langues\n")
        f.write("--       Les traductions pourront être ajoutées/améliorées ultérieurement\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for i, code_data in enumerate(codes):
            if (i + 1) % 500 == 0:
                print(f"   ... {i+1:,} / {len(codes):,} codes traités")
            
            nomenclature = code_data['nomenclature'].lower()
            code = sanitize_id(code_data['code'])
            record_id = f"{nomenclature}_{code}"
            
            # Traductions libellé long
            libelle_long = escape_string(code_data.get('libelle_long', ''))
            key_long = f"i18n_activity_code_{record_id}_long"
            
            for lang in ACTIVE_LANGUAGES:
                # Pour l'instant, utiliser le français pour toutes les langues
                # TODO: Ajouter vraies traductions pour en, es, de, it
                f.write(f"RELATE i18n_key:{key_long}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{libelle_long}';\n\n")
            
            # Traductions libellé moyen
            if code_data.get('libelle_moyen'):
                libelle_moyen = escape_string(code_data.get('libelle_moyen', ''))
                key_moyen = f"i18n_activity_code_{record_id}_moyen"
                
                for lang in ACTIVE_LANGUAGES:
                    f.write(f"RELATE i18n_key:{key_moyen}->i18n_translation->i18n_language:{lang}\n")
                    f.write(f"    SET text = '{libelle_moyen}';\n\n")
            
            # Traductions libellé court
            if code_data.get('libelle_court'):
                libelle_court = escape_string(code_data.get('libelle_court', ''))
                key_court = f"i18n_activity_code_{record_id}_court"
                
                for lang in ACTIVE_LANGUAGES:
                    f.write(f"RELATE i18n_key:{key_court}->i18n_translation->i18n_language:{lang}\n")
                    f.write(f"    SET text = '{libelle_court}';\n\n")
    
    print(f"   ✅ {len(codes) * 3 * 5:,} traductions générées")
    print()
    
    # 3. Générer les seeds
    print("3️⃣  Seeds de la table principale...")
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_activity_code\n")
        f.write(f"-- Total: {len(codes):,} codes\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
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
            f.write("-- " + "-" * 97 + "\n\n")
            
            # Trier par niveau
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
                
                # Keys i18n
                key_long = f"i18n_activity_code_{record_id}_long"
                key_moyen = f"i18n_activity_code_{record_id}_moyen" if code_data.get('libelle_moyen') else None
                key_court = f"i18n_activity_code_{record_id}_court" if code_data.get('libelle_court') else None
                
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
                f.write(f"    libelle_long_i18n_key = i18n_key:{key_long},\n")
                f.write(f"    libelle_moyen_i18n_key = {'i18n_key:' + key_moyen if key_moyen else 'NONE'},\n")
                f.write(f"    libelle_court_i18n_key = {'i18n_key:' + key_court if key_court else 'NONE'};\n")
                f.write("\n")
    
    print(f"   ✅ {len(codes):,} seeds générés")
    print()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print(f"   1. {i18n_keys_file.name}")
    print(f"      → {len(codes) * 3:,} i18n keys")
    print()
    print(f"   2. {i18n_trans_file.name} ⚠️  TRÈS GROS")
    print(f"      → {len(codes) * 3 * 5:,} traductions")
    print()
    print(f"   3. {seeds_file.name}")
    print(f"      → {len(codes):,} seeds")
    print()
    print("⚠️  Note: Les traductions sont actuellement en français pour toutes les langues.")
    print("   Vous pourrez ajouter les vraies traductions en/es/de/it ultérieurement.")
    print()
    print("=" * 100)

if __name__ == "__main__":
    generate_activity_code_i18n_seeds()

