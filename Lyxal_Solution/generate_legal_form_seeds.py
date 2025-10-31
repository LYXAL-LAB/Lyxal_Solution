#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds avec i18n pour les formes juridiques
"""

import json
from pathlib import Path

ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    return s.replace("'", "\\'")

# Traductions des libellés juridiques clés
LEGAL_TRANSLATIONS = {
    'en': {
        # Termes généraux
        'Entrepreneur individuel': 'Sole proprietor',
        'Société': 'Company',
        'Groupement': 'Group',
        'Personne morale': 'Legal entity',
        'droit privé': 'private law',
        'droit public': 'public law',
        'droit étranger': 'foreign law',
        
        # Types spécifiques
        'Société à responsabilité limitée': 'Limited liability company',
        'SARL': 'LLC',
        'Société par actions simplifiée': 'Simplified joint-stock company',
        'SAS': 'Simplified joint-stock company',
        'Société anonyme': 'Public limited company',
        'SA': 'Public limited company',
        'Société en nom collectif': 'General partnership',
        'Société en commandite': 'Limited partnership',
        'Société civile': 'Civil company',
        'Association': 'Association',
        'Coopérative': 'Cooperative',
        
        # Connecteurs
        'et': 'and',
        'ou': 'or',
        'de': 'of',
        'd\'': 'of',
        'à': 'to',
        'en': 'in',
        'non': 'non',
        'sans': 'without',
        'avec': 'with',
    },
    'es': {
        'Entrepreneur individuel': 'Empresario individual',
        'Société': 'Sociedad',
        'Groupement': 'Agrupación',
        'Personne morale': 'Persona jurídica',
        'droit privé': 'derecho privado',
        'droit public': 'derecho público',
        'droit étranger': 'derecho extranjero',
        
        'Société à responsabilité limitée': 'Sociedad de responsabilidad limitada',
        'SARL': 'SRL',
        'Société par actions simplifiée': 'Sociedad por acciones simplificada',
        'SAS': 'SAS',
        'Société anonyme': 'Sociedad anónima',
        'SA': 'SA',
        'Société en nom collectif': 'Sociedad colectiva',
        'Société en commandite': 'Sociedad comanditaria',
        'Société civile': 'Sociedad civil',
        'Association': 'Asociación',
        'Coopérative': 'Cooperativa',
        
        'et': 'y',
        'ou': 'o',
        'de': 'de',
        'd\'': 'de',
        'à': 'a',
        'en': 'en',
        'non': 'no',
        'sans': 'sin',
        'avec': 'con',
    },
    'de': {
        'Entrepreneur individuel': 'Einzelunternehmer',
        'Société': 'Gesellschaft',
        'Groupement': 'Gruppe',
        'Personne morale': 'Juristische Person',
        'droit privé': 'Privatrecht',
        'droit public': 'öffentliches Recht',
        'droit étranger': 'ausländisches Recht',
        
        'Société à responsabilité limitée': 'Gesellschaft mit beschränkter Haftung',
        'SARL': 'GmbH',
        'Société par actions simplifiée': 'Vereinfachte Aktiengesellschaft',
        'SAS': 'Vereinfachte AG',
        'Société anonyme': 'Aktiengesellschaft',
        'SA': 'AG',
        'Société en nom collectif': 'Offene Handelsgesellschaft',
        'Société en commandite': 'Kommanditgesellschaft',
        'Société civile': 'Bürgerliche Gesellschaft',
        'Association': 'Verein',
        'Coopérative': 'Genossenschaft',
        
        'et': 'und',
        'ou': 'oder',
        'de': 'von',
        'd\'': 'von',
        'à': 'zu',
        'en': 'in',
        'non': 'nicht',
        'sans': 'ohne',
        'avec': 'mit',
    },
    'it': {
        'Entrepreneur individuel': 'Imprenditore individuale',
        'Société': 'Società',
        'Groupement': 'Raggruppamento',
        'Personne morale': 'Persona giuridica',
        'droit privé': 'diritto privato',
        'droit public': 'diritto pubblico',
        'droit étranger': 'diritto straniero',
        
        'Société à responsabilité limitée': 'Società a responsabilità limitata',
        'SARL': 'SRL',
        'Société par actions simplifiée': 'Società per azioni semplificata',
        'SAS': 'SPA semplificata',
        'Société anonyme': 'Società per azioni',
        'SA': 'SPA',
        'Société en nom collectif': 'Società in nome collettivo',
        'Société en commandite': 'Società in accomandita',
        'Société civile': 'Società civile',
        'Association': 'Associazione',
        'Coopérative': 'Cooperativa',
        
        'et': 'e',
        'ou': 'o',
        'de': 'di',
        'd\'': 'di',
        'à': 'a',
        'en': 'in',
        'non': 'non',
        'sans': 'senza',
        'avec': 'con',
    }
}

def translate_legal_text(text, target_lang):
    """Traduit un libellé juridique"""
    if not text or target_lang not in LEGAL_TRANSLATIONS:
        return text
    
    translations = LEGAL_TRANSLATIONS[target_lang]
    translated = text
    
    # Traduire les correspondances exactes d'abord
    if text in translations:
        return translations[text]
    
    # Traduire les termes
    import re
    for fr_term, translated_term in sorted(translations.items(), key=lambda x: -len(x[0])):
        pattern = r'\b' + re.escape(fr_term) + r'\b'
        translated = re.sub(pattern, translated_term, translated, flags=re.IGNORECASE)
    
    return translated

def generate_legal_form_seeds():
    """Génère tous les seeds pour les formes juridiques"""
    
    input_file = Path("legal_forms_complete.json")
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS POUR LES FORMES JURIDIQUES")
    print("=" * 100)
    print()
    
    # Charger les données
    with open(input_file, 'r', encoding='utf-8') as f:
        legal_forms = json.load(f)
    
    print(f"✅ {len(legal_forms)} formes juridiques chargées")
    print()
    
    # Grouper par niveau
    by_level = {1: [], 2: [], 3: []}
    for form in legal_forms:
        by_level[form['niveau']].append(form)
    
    print("Répartition:")
    for level, forms in by_level.items():
        print(f"   Niveau {level}: {len(forms)} formes")
    print()
    
    # === 1. GÉNÉRER LES NIVEAUX ===
    print("1️⃣  Génération des niveaux hiérarchiques...")
    
    levels_i18n_keys = output_dir / "business_legal_form_level_i18n_keys.surql"
    levels_i18n_trans = output_dir / "business_legal_form_level_i18n_translations.surql"
    levels_seeds = output_dir / "business_legal_form_level_seeds.surql"
    
    levels_data = [
        {
            'id': 'level_1',
            'code': 'level_1',
            'level_number': 1,
            'code_length': 1,
            'is_terminal': False,
            'sort_order': 1,
            'name': {
                'fr': 'Niveau I',
                'en': 'Level I',
                'es': 'Nivel I',
                'de': 'Stufe I',
                'it': 'Livello I'
            },
            'description': {
                'fr': 'Grandes catégories juridiques (10 catégories)',
                'en': 'Major legal categories (10 categories)',
                'es': 'Grandes categorías jurídicas (10 categorías)',
                'de': 'Große juristische Kategorien (10 Kategorien)',
                'it': 'Grandi categorie giuridiche (10 categorie)'
            }
        },
        {
            'id': 'level_2',
            'code': 'level_2',
            'level_number': 2,
            'code_length': 2,
            'is_terminal': False,
            'sort_order': 2,
            'name': {
                'fr': 'Niveau II',
                'en': 'Level II',
                'es': 'Nivel II',
                'de': 'Stufe II',
                'it': 'Livello II'
            },
            'description': {
                'fr': 'Catégories juridiques moyennes (38 catégories)',
                'en': 'Medium legal categories (38 categories)',
                'es': 'Categorías jurídicas medias (38 categorías)',
                'de': 'Mittlere juristische Kategorien (38 Kategorien)',
                'it': 'Categorie giuridiche medie (38 categorie)'
            }
        },
        {
            'id': 'level_3',
            'code': 'level_3',
            'level_number': 3,
            'code_length': 4,
            'is_terminal': True,
            'sort_order': 3,
            'name': {
                'fr': 'Niveau III',
                'en': 'Level III',
                'es': 'Nivel III',
                'de': 'Stufe III',
                'it': 'Livello III'
            },
            'description': {
                'fr': 'Catégories juridiques détaillées - Utilisées dans SIRENE (259 catégories)',
                'en': 'Detailed legal categories - Used in SIRENE (259 categories)',
                'es': 'Categorías jurídicas detalladas - Utilizadas en SIRENE (259 categorías)',
                'de': 'Detaillierte juristische Kategorien - In SIRENE verwendet (259 Kategorien)',
                'it': 'Categorie giuridiche dettagliate - Utilizzate in SIRENE (259 categorie)'
            }
        }
    ]
    
    # i18n keys
    with open(levels_i18n_keys, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_legal_form_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels_data:
            name_key = f"i18n_legal_form_level_{level['id']}_name"
            desc_key = f"i18n_legal_form_level_{level['id']}_description"
            
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Nom du niveau {level['code']}';\n\n")
            
            f.write(f"CREATE i18n_key:{desc_key} SET\n")
            f.write(f"    description = 'Description du niveau {level['code']}';\n\n")
    
    # i18n translations
    with open(levels_i18n_trans, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_legal_form_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels_data:
            name_key = f"i18n_legal_form_level_{level['id']}_name"
            desc_key = f"i18n_legal_form_level_{level['id']}_description"
            
            f.write(f"-- {level['name']['fr']}\n")
            f.write("-" * 100 + "\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(level['name'][lang])}';\n\n")
            
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{desc_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(level['description'][lang])}';\n\n")
    
    # Seeds
    with open(levels_seeds, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_legal_form_level\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level in levels_data:
            name_key = f"i18n_legal_form_level_{level['id']}_name"
            desc_key = f"i18n_legal_form_level_{level['id']}_description"
            
            f.write(f"CREATE business_legal_form_level:{level['id']} SET\n")
            f.write(f"    code = '{level['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    description_i18n_key = i18n_key:{desc_key},\n")
            f.write(f"    level_number = {level['level_number']},\n")
            f.write(f"    code_length = {level['code_length']},\n")
            f.write(f"    is_terminal = {str(level['is_terminal']).lower()},\n")
            f.write(f"    sort_order = {level['sort_order']};\n\n")
    
    print(f"   ✅ 3 niveaux générés")
    print()
    
    # === 2. GÉNÉRER LES FORMES JURIDIQUES ===
    print("2️⃣  Génération des formes juridiques...")
    
    forms_i18n_keys = output_dir / "business_legal_form_i18n_keys.surql"
    forms_i18n_trans = output_dir / "business_legal_form_i18n_translations.surql"
    forms_seeds = output_dir / "business_legal_form_seeds.surql"
    
    # i18n keys
    with open(forms_i18n_keys, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_legal_form\n")
        f.write(f"-- Total: {len(legal_forms)} formes juridiques\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for form in legal_forms:
            key_name = f"i18n_legal_form_{form['code']}_name"
            f.write(f"CREATE i18n_key:{key_name} SET\n")
            f.write(f"    description = 'Forme juridique {form['code']}: {escape_string(form['libelle'])}';\n\n")
    
    print(f"   ✅ {len(legal_forms)} i18n keys générées")
    
    # i18n translations
    with open(forms_i18n_trans, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_legal_form\n")
        f.write(f"-- Total: {len(legal_forms)} × 5 langues = {len(legal_forms) * 5} traductions\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for i, form in enumerate(legal_forms):
            if (i + 1) % 50 == 0:
                print(f"      ... {i+1} / {len(legal_forms)} formes traduites")
            
            key_name = f"i18n_legal_form_{form['code']}_name"
            libelle_fr = form['libelle']
            
            # Français
            f.write(f"RELATE i18n_key:{key_name}->i18n_translation->i18n_language:fr\n")
            f.write(f"    SET text = '{escape_string(libelle_fr)}';\n\n")
            
            # Autres langues
            for lang in ['en', 'es', 'de', 'it']:
                translated = translate_legal_text(libelle_fr, lang)
                f.write(f"RELATE i18n_key:{key_name}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(translated)}';\n\n")
    
    print(f"   ✅ {len(legal_forms) * 5} traductions générées")
    print()
    
    # Seeds
    with open(forms_seeds, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_legal_form\n")
        f.write(f"-- Total: {len(legal_forms)} formes juridiques\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for level_num in [1, 2, 3]:
            forms = by_level[level_num]
            f.write(f"-- Niveau {level_num} ({len(forms)} formes)\n")
            f.write("-- " + "-" * 97 + "\n\n")
            
            for form in forms:
                key_name = f"i18n_legal_form_{form['code']}_name"
                level_id = f"business_legal_form_level:level_{level_num}"
                
                # Parent
                parent_code = form.get('parent_code')
                if parent_code:
                    parent_id = f"business_legal_form:cj_{parent_code}"
                else:
                    parent_id = "NONE"
                
                f.write(f"CREATE business_legal_form:cj_{form['code']} SET\n")
                f.write(f"    code = '{form['code']}',\n")
                f.write(f"    level = {level_id},\n")
                f.write(f"    parent_code = {parent_id},\n")
                f.write(f"    name_i18n_key = i18n_key:{key_name};\n\n")
    
    print(f"   ✅ {len(legal_forms)} seeds générés")
    print()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print("business_legal_form_level:")
    print("  - business_legal_form_level_i18n_keys.surql (6 keys)")
    print("  - business_legal_form_level_i18n_translations.surql (30 traductions)")
    print("  - business_legal_form_level_seeds.surql (3 seeds)")
    print()
    print("business_legal_form:")
    print(f"  - business_legal_form_i18n_keys.surql ({len(legal_forms)} keys)")
    print(f"  - business_legal_form_i18n_translations.surql ({len(legal_forms) * 5} traductions)")
    print(f"  - business_legal_form_seeds.surql ({len(legal_forms)} seeds)")
    print()
    print("=" * 100)

if __name__ == "__main__":
    generate_legal_form_seeds()

