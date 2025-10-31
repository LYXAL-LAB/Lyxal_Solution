#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds avec i18n pour les tranches d'effectifs (NOMENCLATURE OFFICIELLE TEFET)
"""

from pathlib import Path

ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    return s.replace("'", "\\'")

# Nomenclature officielle TEFET (14 codes)
WORKFORCE_RANGES = [
    {
        'code': 'NN',
        'min': None,
        'max': None,
        'sort_order': 0,
        'labels': {
            'fr': 'Effectif inconnu',
            'en': 'Unknown workforce',
            'es': 'Efectivo desconocido',
            'de': 'Unbekannte Belegschaft',
            'it': 'Effettivo sconosciuto'
        }
    },
    {
        'code': '00',
        'min': 0,
        'max': 0,
        'sort_order': 1,
        'labels': {
            'fr': '0 salarié',
            'en': '0 employee',
            'es': '0 empleado',
            'de': '0 Beschäftigter',
            'it': '0 dipendente'
        }
    },
    {
        'code': '01',
        'min': 1,
        'max': 2,
        'sort_order': 2,
        'labels': {
            'fr': '1 ou 2 salariés',
            'en': '1 or 2 employees',
            'es': '1 o 2 empleados',
            'de': '1 oder 2 Beschäftigte',
            'it': '1 o 2 dipendenti'
        }
    },
    {
        'code': '02',
        'min': 3,
        'max': 5,
        'sort_order': 3,
        'labels': {
            'fr': '3 à 5 salariés',
            'en': '3 to 5 employees',
            'es': '3 a 5 empleados',
            'de': '3 bis 5 Beschäftigte',
            'it': '3 a 5 dipendenti'
        }
    },
    {
        'code': '03',
        'min': 6,
        'max': 9,
        'sort_order': 4,
        'labels': {
            'fr': '6 à 9 salariés',
            'en': '6 to 9 employees',
            'es': '6 a 9 empleados',
            'de': '6 bis 9 Beschäftigte',
            'it': '6 a 9 dipendenti'
        }
    },
    {
        'code': '11',
        'min': 10,
        'max': 19,
        'sort_order': 5,
        'labels': {
            'fr': '10 à 19 salariés',
            'en': '10 to 19 employees',
            'es': '10 a 19 empleados',
            'de': '10 bis 19 Beschäftigte',
            'it': '10 a 19 dipendenti'
        }
    },
    {
        'code': '12',
        'min': 20,
        'max': 49,
        'sort_order': 6,
        'labels': {
            'fr': '20 à 49 salariés',
            'en': '20 to 49 employees',
            'es': '20 a 49 empleados',
            'de': '20 bis 49 Beschäftigte',
            'it': '20 a 49 dipendenti'
        }
    },
    {
        'code': '21',
        'min': 50,
        'max': 99,
        'sort_order': 7,
        'labels': {
            'fr': '50 à 99 salariés',
            'en': '50 to 99 employees',
            'es': '50 a 99 empleados',
            'de': '50 bis 99 Beschäftigte',
            'it': '50 a 99 dipendenti'
        }
    },
    {
        'code': '22',
        'min': 100,
        'max': 199,
        'sort_order': 8,
        'labels': {
            'fr': '100 à 199 salariés',
            'en': '100 to 199 employees',
            'es': '100 a 199 empleados',
            'de': '100 bis 199 Beschäftigte',
            'it': '100 a 199 dipendenti'
        }
    },
    {
        'code': '31',
        'min': 200,
        'max': 499,
        'sort_order': 9,
        'labels': {
            'fr': '200 à 499 salariés',
            'en': '200 to 499 employees',
            'es': '200 a 499 empleados',
            'de': '200 bis 499 Beschäftigte',
            'it': '200 a 499 dipendenti'
        }
    },
    {
        'code': '41',
        'min': 500,
        'max': 999,
        'sort_order': 10,
        'labels': {
            'fr': '500 à 999 salariés',
            'en': '500 to 999 employees',
            'es': '500 a 999 empleados',
            'de': '500 bis 999 Beschäftigte',
            'it': '500 a 999 dipendenti'
        }
    },
    {
        'code': '42',
        'min': 1000,
        'max': 1999,
        'sort_order': 11,
        'labels': {
            'fr': '1 000 à 1 999 salariés',
            'en': '1,000 to 1,999 employees',
            'es': '1.000 a 1.999 empleados',
            'de': '1.000 bis 1.999 Beschäftigte',
            'it': '1.000 a 1.999 dipendenti'
        }
    },
    {
        'code': '51',
        'min': 2000,
        'max': 4999,
        'sort_order': 12,
        'labels': {
            'fr': '2 000 à 4 999 salariés',
            'en': '2,000 to 4,999 employees',
            'es': '2.000 a 4.999 empleados',
            'de': '2.000 bis 4.999 Beschäftigte',
            'it': '2.000 a 4.999 dipendenti'
        }
    },
    {
        'code': '52',
        'min': 5000,
        'max': None,
        'sort_order': 13,
        'labels': {
            'fr': '5 000 salariés ou plus',
            'en': '5,000 employees or more',
            'es': '5.000 empleados o más',
            'de': '5.000 Beschäftigte oder mehr',
            'it': '5.000 dipendenti o più'
        }
    }
]

def generate_workforce_seeds():
    """Génère tous les seeds pour les tranches d'effectifs"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS POUR LES TRANCHES D'EFFECTIFS")
    print("=" * 100)
    print()
    
    print(f"✅ {len(WORKFORCE_RANGES)} tranches d'effectifs (nomenclature officielle TEFET)")
    print()
    
    # === i18n keys ===
    i18n_keys_file = output_dir / "business_workforce_range_i18n_keys.surql"
    
    print("1️⃣  Génération des i18n keys...")
    
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_workforce_range\n")
        f.write(f"-- Total: {len(WORKFORCE_RANGES)} tranches d'effectifs (nomenclature officielle TEFET)\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for range_data in WORKFORCE_RANGES:
            key_name = f"i18n_workforce_range_{range_data['code'].lower()}_name"
            label_fr = range_data['labels']['fr']
            
            f.write(f"CREATE i18n_key:{key_name} SET\n")
            f.write(f"    description = 'Tranche d\\'effectifs {range_data['code']}: {escape_string(label_fr)}';\n\n")
    
    print(f"   ✅ {len(WORKFORCE_RANGES)} i18n keys générées")
    print()
    
    # === i18n translations ===
    i18n_trans_file = output_dir / "business_workforce_range_i18n_translations.surql"
    
    print("2️⃣  Génération des i18n translations...")
    
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_workforce_range\n")
        f.write(f"-- Total: {len(WORKFORCE_RANGES)} × 5 langues = {len(WORKFORCE_RANGES) * 5} traductions\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for range_data in WORKFORCE_RANGES:
            key_name = f"i18n_workforce_range_{range_data['code'].lower()}_name"
            
            f.write(f"-- Tranche {range_data['code']}: {range_data['labels']['fr']}\n")
            f.write("-" * 100 + "\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                label = range_data['labels'][lang]
                f.write(f"RELATE i18n_key:{key_name}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(label)}';\n\n")
    
    print(f"   ✅ {len(WORKFORCE_RANGES) * 5} traductions générées")
    print()
    
    # === Seeds ===
    seeds_file = output_dir / "business_workforce_range_seeds.surql"
    
    print("3️⃣  Génération des seeds...")
    
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_workforce_range\n")
        f.write(f"-- Total: {len(WORKFORCE_RANGES)} tranches d'effectifs (nomenclature officielle TEFET)\n")
        f.write("-- Source: Documentation INSEE - Champ TEFET\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for range_data in WORKFORCE_RANGES:
            key_name = f"i18n_workforce_range_{range_data['code'].lower()}_name"
            
            min_val = str(range_data['min']) if range_data['min'] is not None else 'NONE'
            max_val = str(range_data['max']) if range_data['max'] is not None else 'NONE'
            
            f.write(f"CREATE business_workforce_range:wr_{range_data['code'].lower()} SET\n")
            f.write(f"    code = '{range_data['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{key_name},\n")
            f.write(f"    min_employees = {min_val},\n")
            f.write(f"    max_employees = {max_val},\n")
            f.write(f"    sort_order = {range_data['sort_order']};\n\n")
    
    print(f"   ✅ {len(WORKFORCE_RANGES)} seeds générés")
    print()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print(f"  - business_workforce_range_i18n_keys.surql ({len(WORKFORCE_RANGES)} keys)")
    print(f"  - business_workforce_range_i18n_translations.surql ({len(WORKFORCE_RANGES) * 5} traductions)")
    print(f"  - business_workforce_range_seeds.surql ({len(WORKFORCE_RANGES)} seeds)")
    print()
    print("📊 Détail des tranches (nomenclature officielle TEFET):")
    print()
    for range_data in WORKFORCE_RANGES:
        min_str = f"{range_data['min']:,}" if range_data['min'] is not None else '?'
        max_str = f"{range_data['max']:,}" if range_data['max'] is not None else '∞'
        print(f"   {range_data['code']}: {range_data['labels']['fr']:.<45} [{min_str} - {max_str}]")
    print()
    print("⚠️  ATTENTION: Les codes 32 et 53 trouvés dans les données ne sont PAS officiels")
    print("    → Ils doivent être remappés lors de l'import:")
    print("       32 (250-499) → 31 (200-499)")
    print("       53 (10000+)  → 52 (5000+)")
    print()
    print("=" * 100)

if __name__ == "__main__":
    generate_workforce_seeds()

