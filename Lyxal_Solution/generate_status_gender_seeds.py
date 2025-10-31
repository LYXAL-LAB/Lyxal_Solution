#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds avec i18n pour les statuts administratifs et les genres
"""

from pathlib import Path

ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    return s.replace("'", "\\'")

# États administratifs (2 codes)
ADMINISTRATIVE_STATUSES = [
    {
        'code': 'A',
        'is_active': True,
        'sort_order': 1,
        'name': {
            'fr': 'Active',
            'en': 'Active',
            'es': 'Activa',
            'de': 'Aktiv',
            'it': 'Attiva'
        },
        'description': {
            'fr': 'Unité légale en activité',
            'en': 'Legal unit in operation',
            'es': 'Unidad legal en actividad',
            'de': 'Betriebene Rechtseinheit',
            'it': 'Unità legale in attività'
        }
    },
    {
        'code': 'C',
        'is_active': False,
        'sort_order': 2,
        'name': {
            'fr': 'Cessée',
            'en': 'Ceased',
            'es': 'Cesada',
            'de': 'Eingestellt',
            'it': 'Cessata'
        },
        'description': {
            'fr': 'Unité légale ayant cessé son activité',
            'en': 'Legal unit that has ceased operations',
            'es': 'Unidad legal que ha cesado su actividad',
            'de': 'Rechtseinheit, die ihren Betrieb eingestellt hat',
            'it': 'Unità legale che ha cessato l\'attività'
        }
    }
]

# Genres (3 codes)
GENDERS = [
    {
        'code': 'M',
        'sort_order': 1,
        'name': {
            'fr': 'Masculin',
            'en': 'Male',
            'es': 'Masculino',
            'de': 'Männlich',
            'it': 'Maschile'
        }
    },
    {
        'code': 'F',
        'sort_order': 2,
        'name': {
            'fr': 'Féminin',
            'en': 'Female',
            'es': 'Femenino',
            'de': 'Weiblich',
            'it': 'Femminile'
        }
    },
    {
        'code': 'ND',
        'sort_order': 3,
        'name': {
            'fr': 'Non diffusé',
            'en': 'Not disclosed',
            'es': 'No difundido',
            'de': 'Nicht verbreitet',
            'it': 'Non diffuso'
        }
    }
]

def generate_status_seeds():
    """Génère les seeds pour les statuts administratifs"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    print("=" * 100)
    print("1️⃣  STATUTS ADMINISTRATIFS")
    print("=" * 100)
    print()
    
    print(f"✅ {len(ADMINISTRATIVE_STATUSES)} statuts administratifs")
    print()
    
    # i18n keys
    i18n_keys_file = output_dir / "business_administrative_status_i18n_keys.surql"
    
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_administrative_status\n")
        f.write(f"-- Total: {len(ADMINISTRATIVE_STATUSES)} statuts\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for status in ADMINISTRATIVE_STATUSES:
            name_key = f"i18n_admin_status_{status['code'].lower()}_name"
            desc_key = f"i18n_admin_status_{status['code'].lower()}_description"
            
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Statut administratif {status['code']}: {status['name']['fr']}';\n\n")
            
            f.write(f"CREATE i18n_key:{desc_key} SET\n")
            f.write(f"    description = 'Description du statut {status['code']}';\n\n")
    
    print(f"   ✅ {len(ADMINISTRATIVE_STATUSES) * 2} i18n keys générées")
    
    # i18n translations
    i18n_trans_file = output_dir / "business_administrative_status_i18n_translations.surql"
    
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_administrative_status\n")
        f.write(f"-- Total: {len(ADMINISTRATIVE_STATUSES) * 2 * 5} traductions\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for status in ADMINISTRATIVE_STATUSES:
            name_key = f"i18n_admin_status_{status['code'].lower()}_name"
            desc_key = f"i18n_admin_status_{status['code'].lower()}_description"
            
            f.write(f"-- Statut {status['code']}: {status['name']['fr']}\n")
            f.write("-" * 100 + "\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(status['name'][lang])}';\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{desc_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(status['description'][lang])}';\n\n")
    
    print(f"   ✅ {len(ADMINISTRATIVE_STATUSES) * 2 * 5} traductions générées")
    
    # Seeds
    seeds_file = output_dir / "business_administrative_status_seeds.surql"
    
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_administrative_status\n")
        f.write(f"-- Total: {len(ADMINISTRATIVE_STATUSES)} statuts\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for status in ADMINISTRATIVE_STATUSES:
            name_key = f"i18n_admin_status_{status['code'].lower()}_name"
            desc_key = f"i18n_admin_status_{status['code'].lower()}_description"
            
            f.write(f"CREATE business_administrative_status:status_{status['code'].lower()} SET\n")
            f.write(f"    code = '{status['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    description_i18n_key = i18n_key:{desc_key},\n")
            f.write(f"    is_active = {str(status['is_active']).lower()},\n")
            f.write(f"    sort_order = {status['sort_order']};\n\n")
    
    print(f"   ✅ {len(ADMINISTRATIVE_STATUSES)} seeds générés")
    print()

def generate_gender_seeds():
    """Génère les seeds pour les genres"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    print("=" * 100)
    print("2️⃣  GENRES")
    print("=" * 100)
    print()
    
    print(f"✅ {len(GENDERS)} genres")
    print()
    
    # i18n keys
    i18n_keys_file = output_dir / "business_gender_i18n_keys.surql"
    
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_gender\n")
        f.write(f"-- Total: {len(GENDERS)} genres\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for gender in GENDERS:
            name_key = f"i18n_gender_{gender['code'].lower()}_name"
            
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Genre {gender['code']}: {gender['name']['fr']}';\n\n")
    
    print(f"   ✅ {len(GENDERS)} i18n keys générées")
    
    # i18n translations
    i18n_trans_file = output_dir / "business_gender_i18n_translations.surql"
    
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_gender\n")
        f.write(f"-- Total: {len(GENDERS) * 5} traductions\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for gender in GENDERS:
            name_key = f"i18n_gender_{gender['code'].lower()}_name"
            
            f.write(f"-- Genre {gender['code']}: {gender['name']['fr']}\n")
            f.write("-" * 100 + "\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(gender['name'][lang])}';\n\n")
    
    print(f"   ✅ {len(GENDERS) * 5} traductions générées")
    
    # Seeds
    seeds_file = output_dir / "business_gender_seeds.surql"
    
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_gender\n")
        f.write(f"-- Total: {len(GENDERS)} genres\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for gender in GENDERS:
            name_key = f"i18n_gender_{gender['code'].lower()}_name"
            
            f.write(f"CREATE business_gender:gender_{gender['code'].lower()} SET\n")
            f.write(f"    code = '{gender['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    sort_order = {gender['sort_order']};\n\n")
    
    print(f"   ✅ {len(GENDERS)} seeds générés")
    print()

def main():
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS - STATUTS ADMINISTRATIFS & GENRES")
    print("=" * 100)
    print()
    
    generate_status_seeds()
    generate_gender_seeds()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print("business_administrative_status:")
    print(f"  - business_administrative_status_i18n_keys.surql (4 keys)")
    print(f"  - business_administrative_status_i18n_translations.surql (20 traductions)")
    print(f"  - business_administrative_status_seeds.surql (2 seeds)")
    print()
    print("business_gender:")
    print(f"  - business_gender_i18n_keys.surql (3 keys)")
    print(f"  - business_gender_i18n_translations.surql (15 traductions)")
    print(f"  - business_gender_seeds.surql (3 seeds)")
    print()
    print("📊 Récapitulatif:")
    print()
    print("Statuts administratifs:")
    for status in ADMINISTRATIVE_STATUSES:
        active = "🟢 Active" if status['is_active'] else "🔴 Cessée"
        print(f"   {status['code']}: {status['name']['fr']:.<20} {active}")
    print()
    print("Genres:")
    for gender in GENDERS:
        print(f"   {gender['code']:.<3} {gender['name']['fr']}")
    print()
    print("💡 NOTE: Le champ sexeUniteLegale est NULL pour les personnes morales (sociétés)")
    print("         M et F sont pour les entrepreneurs individuels uniquement")
    print()
    print("=" * 100)

if __name__ == "__main__":
    main()

