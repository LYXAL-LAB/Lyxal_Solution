#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds avec i18n pour les 3 tables business
"""

import json
from pathlib import Path

# Les 5 langues actives du système
ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def sanitize_key(text):
    """Convertit un texte en clé i18n valide"""
    key = text.lower()
    key = key.replace(' ', '_')
    key = key.replace('-', '_')
    key = key.replace("'", '_')
    key = key.replace('é', 'e').replace('è', 'e').replace('ê', 'e')
    key = key.replace('à', 'a').replace('â', 'a')
    key = key.replace('ô', 'o')
    key = key.replace('ù', 'u').replace('û', 'u')
    key = key.replace('ç', 'c')
    key = key.replace('î', 'i')
    return key

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    s = s.replace("'", "\\'")
    return s

def generate_nomenclature_type_seeds():
    """Génère les seeds pour business_nomenclature_type avec i18n"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    nomenclatures = [
        {
            'id': 'nafrev2',
            'code': 'NAFRev2',
            'name': {
                'fr': 'NAF Révision 2',
                'en': 'French Business Classification Revision 2',
                'es': 'Clasificación de Actividades Francesa Revisión 2',
                'de': 'Französische Wirtschaftsklassifizierung Revision 2',
                'it': 'Classificazione delle Attività Francese Revisione 2'
            },
            'description': {
                'fr': 'Nomenclature d\'Activités Française Révision 2 - En vigueur depuis 2008',
                'en': 'French Business Classification Revision 2 - In force since 2008',
                'es': 'Clasificación de Actividades Francesa Revisión 2 - En vigor desde 2008',
                'de': 'Französische Wirtschaftsklassifizierung Revision 2 - Gültig seit 2008',
                'it': 'Classificazione delle Attività Francese Revisione 2 - In vigore dal 2008'
            },
            'period_start': 2008,
            'period_end': None,
            'is_active': True,
            'sort_order': 1
        },
        {
            'id': 'nafrev1',
            'code': 'NAFRev1',
            'name': {
                'fr': 'NAF Révision 1',
                'en': 'French Business Classification Revision 1',
                'es': 'Clasificación de Actividades Francesa Revisión 1',
                'de': 'Französische Wirtschaftsklassifizierung Revision 1',
                'it': 'Classificazione delle Attività Francese Revisione 1'
            },
            'description': {
                'fr': 'Nomenclature d\'Activités Française Révision 1 (NAF 2003) - Utilisée de 2003 à 2008',
                'en': 'French Business Classification Revision 1 (NAF 2003) - Used from 2003 to 2008',
                'es': 'Clasificación de Actividades Francesa Revisión 1 (NAF 2003) - Usada de 2003 a 2008',
                'de': 'Französische Wirtschaftsklassifizierung Revision 1 (NAF 2003) - Verwendet von 2003 bis 2008',
                'it': 'Classificazione delle Attività Francese Revisione 1 (NAF 2003) - Usata dal 2003 al 2008'
            },
            'period_start': 2003,
            'period_end': 2008,
            'is_active': False,
            'sort_order': 2
        },
        {
            'id': 'naf1993',
            'code': 'NAF1993',
            'name': {
                'fr': 'NAF 1993',
                'en': 'French Business Classification 1993',
                'es': 'Clasificación de Actividades Francesa 1993',
                'de': 'Französische Wirtschaftsklassifizierung 1993',
                'it': 'Classificazione delle Attività Francese 1993'
            },
            'description': {
                'fr': 'Nomenclature d\'Activités Française 1993 - Utilisée de 1993 à 2003',
                'en': 'French Business Classification 1993 - Used from 1993 to 2003',
                'es': 'Clasificación de Actividades Francesa 1993 - Usada de 1993 a 2003',
                'de': 'Französische Wirtschaftsklassifizierung 1993 - Verwendet von 1993 bis 2003',
                'it': 'Classificazione delle Attività Francese 1993 - Usata dal 1993 al 2003'
            },
            'period_start': 1993,
            'period_end': 2003,
            'is_active': False,
            'sort_order': 3
        },
        {
            'id': 'nap',
            'code': 'NAP',
            'name': {
                'fr': 'NAP',
                'en': 'Product Activities Classification',
                'es': 'Clasificación de Actividades de Productos',
                'de': 'Produktaktivitätsklassifizierung',
                'it': 'Classificazione delle Attività di Prodotto'
            },
            'description': {
                'fr': 'Nomenclature d\'Activités de Produits - Utilisée de 1973 à 1993',
                'en': 'Product Activities Classification - Used from 1973 to 1993',
                'es': 'Clasificación de Actividades de Productos - Usada de 1973 a 1993',
                'de': 'Produktaktivitätsklassifizierung - Verwendet von 1973 bis 1993',
                'it': 'Classificazione delle Attività di Prodotto - Usata dal 1973 al 1993'
            },
            'period_start': 1973,
            'period_end': 1993,
            'is_active': False,
            'sort_order': 4
        }
    ]
    
    # Générer les fichiers
    i18n_keys_file = output_dir / "business_nomenclature_type_i18n_keys.surql"
    i18n_trans_file = output_dir / "business_nomenclature_type_i18n_translations.surql"
    seeds_file = output_dir / "business_nomenclature_type_seeds.surql"
    
    # 1. Générer les i18n keys
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_nomenclature_type\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for nom in nomenclatures:
            # Key pour le nom
            name_key = f"i18n_business_nomenclature_type_{nom['id']}_name"
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Nom du type de nomenclature {nom['code']}';\n\n")
            
            # Key pour la description
            desc_key = f"i18n_business_nomenclature_type_{nom['id']}_description"
            f.write(f"CREATE i18n_key:{desc_key} SET\n")
            f.write(f"    description = 'Description du type de nomenclature {nom['code']}';\n\n")
    
    # 2. Générer les traductions
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_nomenclature_type\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for nom in nomenclatures:
            f.write(f"-- {nom['code']}\n")
            f.write("-" * 100 + "\n\n")
            
            # Traductions du nom
            name_key = f"i18n_business_nomenclature_type_{nom['id']}_name"
            for lang in ACTIVE_LANGUAGES:
                text = escape_string(nom['name'][lang])
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{text}';\n\n")
            
            # Traductions de la description
            desc_key = f"i18n_business_nomenclature_type_{nom['id']}_description"
            for lang in ACTIVE_LANGUAGES:
                text = escape_string(nom['description'][lang])
                f.write(f"RELATE i18n_key:{desc_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{text}';\n\n")
    
    # 3. Générer les seeds de la table
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_nomenclature_type\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for nom in nomenclatures:
            name_key = f"i18n_business_nomenclature_type_{nom['id']}_name"
            desc_key = f"i18n_business_nomenclature_type_{nom['id']}_description"
            
            f.write(f"CREATE business_nomenclature_type:{nom['id']} SET\n")
            f.write(f"    code = '{nom['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    description_i18n_key = i18n_key:{desc_key},\n")
            f.write(f"    period_start = {nom['period_start']},\n")
            f.write(f"    period_end = {'NONE' if nom['period_end'] is None else nom['period_end']},\n")
            f.write(f"    is_active = {str(nom['is_active']).lower()},\n")
            f.write(f"    sort_order = {nom['sort_order']};\n\n")
    
    return len(nomenclatures)

def generate_hierarchical_level_seeds():
    """Génère les seeds pour business_hierarchical_level avec i18n"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    levels = [
        {
            'id': 'section',
            'code': 'section',
            'name': {
                'fr': 'Section',
                'en': 'Section',
                'es': 'Sección',
                'de': 'Sektion',
                'it': 'Sezione'
            },
            'description': {
                'fr': 'Premier niveau de la nomenclature - Grandes familles d\'activités',
                'en': 'First level of classification - Major activity families',
                'es': 'Primer nivel de la clasificación - Grandes familias de actividades',
                'de': 'Erste Ebene der Klassifizierung - Große Aktivitätsfamilien',
                'it': 'Primo livello della classificazione - Grandi famiglie di attività'
            },
            'level_number': 1,
            'is_terminal': False,
            'sort_order': 1
        },
        {
            'id': 'division',
            'code': 'division',
            'name': {
                'fr': 'Division',
                'en': 'Division',
                'es': 'División',
                'de': 'Division',
                'it': 'Divisione'
            },
            'description': {
                'fr': 'Deuxième niveau de la nomenclature - Secteurs d\'activité',
                'en': 'Second level of classification - Activity sectors',
                'es': 'Segundo nivel de la clasificación - Sectores de actividad',
                'de': 'Zweite Ebene der Klassifizierung - Aktivitätssektoren',
                'it': 'Secondo livello della classificazione - Settori di attività'
            },
            'level_number': 2,
            'is_terminal': False,
            'sort_order': 2
        },
        {
            'id': 'groupe',
            'code': 'groupe',
            'name': {
                'fr': 'Groupe',
                'en': 'Group',
                'es': 'Grupo',
                'de': 'Gruppe',
                'it': 'Gruppo'
            },
            'description': {
                'fr': 'Troisième niveau de la nomenclature - Sous-secteurs',
                'en': 'Third level of classification - Sub-sectors',
                'es': 'Tercer nivel de la clasificación - Subsectores',
                'de': 'Dritte Ebene der Klassifizierung - Untersektoren',
                'it': 'Terzo livello della classificazione - Sottosettori'
            },
            'level_number': 3,
            'is_terminal': False,
            'sort_order': 3
        },
        {
            'id': 'classe',
            'code': 'classe',
            'name': {
                'fr': 'Classe',
                'en': 'Class',
                'es': 'Clase',
                'de': 'Klasse',
                'it': 'Classe'
            },
            'description': {
                'fr': 'Quatrième niveau de la nomenclature - Catégories détaillées',
                'en': 'Fourth level of classification - Detailed categories',
                'es': 'Cuarto nivel de la clasificación - Categorías detalladas',
                'de': 'Vierte Ebene der Klassifizierung - Detaillierte Kategorien',
                'it': 'Quarto livello della classificazione - Categorie dettagliate'
            },
            'level_number': 4,
            'is_terminal': False,
            'sort_order': 4
        },
        {
            'id': 'sous_classe',
            'code': 'sous_classe',
            'name': {
                'fr': 'Sous-classe',
                'en': 'Sub-class',
                'es': 'Subclase',
                'de': 'Unterklasse',
                'it': 'Sottoclasse'
            },
            'description': {
                'fr': 'Cinquième niveau de la nomenclature - Codes terminaux assignés aux entreprises',
                'en': 'Fifth level of classification - Terminal codes assigned to companies',
                'es': 'Quinto nivel de la clasificación - Códigos terminales asignados a las empresas',
                'de': 'Fünfte Ebene der Klassifizierung - Endcodes für Unternehmen',
                'it': 'Quinto livello della classificazione - Codici terminali assegnati alle aziende'
            },
            'level_number': 5,
            'is_terminal': True,
            'sort_order': 5
        }
    ]
    
    # Générer les fichiers
    i18n_keys_file = output_dir / "business_hierarchical_level_i18n_keys.surql"
    i18n_trans_file = output_dir / "business_hierarchical_level_i18n_translations.surql"
    seeds_file = output_dir / "business_hierarchical_level_seeds.surql"
    
    # 1. Générer les i18n keys
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_hierarchical_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels:
            # Key pour le nom
            name_key = f"i18n_business_hierarchical_level_{level['id']}_name"
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Nom du niveau hiérarchique {level['code']}';\n\n")
            
            # Key pour la description
            desc_key = f"i18n_business_hierarchical_level_{level['id']}_description"
            f.write(f"CREATE i18n_key:{desc_key} SET\n")
            f.write(f"    description = 'Description du niveau hiérarchique {level['code']}';\n\n")
    
    # 2. Générer les traductions
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_hierarchical_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels:
            f.write(f"-- {level['code']}\n")
            f.write("-" * 100 + "\n\n")
            
            # Traductions du nom
            name_key = f"i18n_business_hierarchical_level_{level['id']}_name"
            for lang in ACTIVE_LANGUAGES:
                text = escape_string(level['name'][lang])
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{text}';\n\n")
            
            # Traductions de la description
            desc_key = f"i18n_business_hierarchical_level_{level['id']}_description"
            for lang in ACTIVE_LANGUAGES:
                text = escape_string(level['description'][lang])
                f.write(f"RELATE i18n_key:{desc_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{text}';\n\n")
    
    # 3. Générer les seeds de la table
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_hierarchical_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels:
            name_key = f"i18n_business_hierarchical_level_{level['id']}_name"
            desc_key = f"i18n_business_hierarchical_level_{level['id']}_description"
            
            f.write(f"CREATE business_hierarchical_level:{level['id']} SET\n")
            f.write(f"    code = '{level['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    description_i18n_key = i18n_key:{desc_key},\n")
            f.write(f"    level_number = {level['level_number']},\n")
            f.write(f"    is_terminal = {str(level['is_terminal']).lower()},\n")
            f.write(f"    sort_order = {level['sort_order']};\n\n")
    
    return len(levels)

def main():
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS I18N POUR LES TABLES BUSINESS")
    print("=" * 100)
    print()
    print(f"Langues actives: {', '.join(ACTIVE_LANGUAGES)}")
    print()
    
    # 1. Nomenclature types
    print("1️⃣  Génération des seeds pour business_nomenclature_type...")
    count1 = generate_nomenclature_type_seeds()
    print(f"   ✅ {count1} types générés avec i18n dans 5 langues")
    print()
    
    # 2. Hierarchical levels
    print("2️⃣  Génération des seeds pour business_hierarchical_level...")
    count2 = generate_hierarchical_level_seeds()
    print(f"   ✅ {count2} niveaux générés avec i18n dans 5 langues")
    print()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print("business_nomenclature_type:")
    print("  - business_nomenclature_type_i18n_keys.surql")
    print("  - business_nomenclature_type_i18n_translations.surql")
    print("  - business_nomenclature_type_seeds.surql")
    print()
    print("business_hierarchical_level:")
    print("  - business_hierarchical_level_i18n_keys.surql")
    print("  - business_hierarchical_level_i18n_translations.surql")
    print("  - business_hierarchical_level_seeds.surql")
    print()
    print("⚠️  Note: Les seeds pour business_activity_code (4 602 codes) seront")
    print("    générés séparément car ils nécessitent la traduction des libellés.")
    print()
    print("=" * 100)

if __name__ == "__main__":
    main()

