#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GENERATION DES SEEDS POUR PARAMETERS
Génère les fichiers .surql pour les seeds, i18n keys et translations
"""

import json
from pathlib import Path
from typing import List, Dict

# Chemins
BASE_DIR = Path(__file__).parent
INPUT_PATH = BASE_DIR / "parameters_flat.json"
OUTPUT_DIR = BASE_DIR

# Configuration
BATCH_SIZE = 3000  # Nombre de parameters par batch
LANGUAGES = {
    'fr': 'Français',
    'en': 'English',
    'it': 'Italiano',
    'de': 'Deutsch',
    'es': 'Español'
}

def load_parameters() -> List[Dict]:
    """Charge les parameters depuis le JSON"""
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def escape_surql_string(text: str) -> str:
    """Échappe une chaîne pour SurrealQL"""
    if not text:
        return ""
    # Remplace les backslashes et quotes
    text = text.replace("\\", "\\\\")
    text = text.replace('"', '\\"')
    text = text.replace("'", "\\'")
    # Remplace les retours à la ligne
    text = text.replace("\n", "\\n")
    text = text.replace("\r", "\\r")
    return text

def translate_text(text: str, lang: str) -> str:
    """Traduit un texte (ici on garde l'anglais pour simplifier)"""
    # Pour une vraie traduction, utiliser une API de traduction
    # Ici on retourne le texte original
    return text

def generate_seed_batch(parameters: List[Dict], batch_num: int) -> str:
    """Génère un fichier seed pour un batch de parameters"""
    lines = []
    lines.append("-- ============================================================================")
    lines.append(f"-- PARAMETER SEEDS - BATCH {batch_num}")
    lines.append(f"-- Total: {len(parameters)} parameters")
    lines.append("-- ============================================================================\n")
    
    for param in parameters:
        param_slug = param['parameter_slug']
        tool_slug = param['tool_slug']
        
        # Valeurs par défaut
        default_value_str = "NONE"
        if param.get('default_value'):
            default_val = param['default_value']
            # Essayer de détecter le type
            if default_val.lower() == 'true':
                default_value_str = "true"
            elif default_val.lower() == 'false':
                default_value_str = "false"
            elif default_val.isdigit():
                default_value_str = default_val
            else:
                default_value_str = f"'{escape_surql_string(default_val)}'"
        
        placeholder_str = f"'{escape_surql_string(param['placeholder'])}'" if param.get('placeholder') else "NONE"
        
        lines.append(f"CREATE parameter:{param_slug} SET")
        lines.append(f"    identity = {{")
        lines.append(f"        name: '{escape_surql_string(param['parameter_name'])}',")
        lines.append(f"        display_name_i18n: i18n_key:{param['i18n_key_name']},")
        lines.append(f"        description_i18n: i18n_key:{param['i18n_key_desc']},")
        lines.append(f"        parameter_type: '{param['parameter_type']}',")
        lines.append(f"        sub_type: NONE")
        lines.append(f"    }},")
        lines.append(f"    presentation = {{")
        lines.append(f"        display_order: {param['display_order']},")
        lines.append(f"        placeholder_i18n: i18n_key:{param['i18n_key_placeholder']},")
        lines.append(f"        help_text_i18n: i18n_key:{param['i18n_key_help']},")
        lines.append(f"        is_sensitive: false,")
        lines.append(f"        is_hidden: false")
        lines.append(f"    }},")
        lines.append(f"    validation = {{")
        lines.append(f"        is_required: {str(param['is_required']).lower()},")
        lines.append(f"        min_value: NONE,")
        lines.append(f"        max_value: NONE,")
        lines.append(f"        min_length: NONE,")
        lines.append(f"        max_length: NONE,")
        lines.append(f"        pattern: NONE,")
        lines.append(f"        format: NONE,")
        lines.append(f"        allowed_values: NONE")
        lines.append(f"    }},")
        lines.append(f"    config = {{")
        lines.append(f"        default_value: {default_value_str},")
        lines.append(f"        options: NONE,")
        lines.append(f"        display_conditions: NONE")
        lines.append(f"    }},")
        lines.append(f"    documentation = NONE,")
        lines.append(f"    metadata = {{")
        lines.append(f"        created_at: time::now(),")
        lines.append(f"        updated_at: time::now(),")
        lines.append(f"        created_by: NONE,")
        lines.append(f"        updated_by: NONE,")
        lines.append(f"        version: 1,")
        lines.append(f"        etag: rand::uuid::v7(),")
        lines.append(f"        tags: [],")
        lines.append(f"        custom_data: {{}}")
        lines.append(f"    }},")
        lines.append(f"    tool_id: tool:{tool_slug},")
        lines.append(f"    is_active: true;")
        lines.append("")
    
    return "\n".join(lines)

def generate_i18n_keys_batch(parameters: List[Dict], batch_num: int) -> str:
    """Génère les clés i18n pour un batch"""
    lines = []
    lines.append("-- ============================================================================")
    lines.append(f"-- I18N KEYS - PARAMETER BATCH {batch_num}")
    lines.append(f"-- Total: {len(parameters) * 4} keys (4 per parameter)")
    lines.append("-- ============================================================================\n")
    
    for param in parameters:
        # 4 clés par parameter: name, desc, placeholder, help
        keys = [
            (param['i18n_key_name'], f"Parameter name: {param['display_name']}"),
            (param['i18n_key_desc'], f"Parameter description: {param['description'][:50] if param.get('description') else param['display_name']}"),
            (param['i18n_key_placeholder'], f"Parameter placeholder: {param['placeholder'][:50] if param.get('placeholder') else param['display_name']}"),
            (param['i18n_key_help'], f"Parameter help: {param['display_name']}")
        ]
        
        for key_name, key_desc in keys:
            lines.append(f"CREATE i18n_key:{key_name} SET")
            lines.append(f"    identity = {{")
            lines.append(f"        key: '{key_name}',")
            lines.append(f"        description: '{escape_surql_string(key_desc)}',")
            lines.append(f"        context: 'parameter',")
            lines.append(f"        category: 'integration'")
            lines.append(f"    }},")
            lines.append(f"    metadata = {{")
            lines.append(f"        created_at: time::now(),")
            lines.append(f"        updated_at: time::now(),")
            lines.append(f"        version: 1")
            lines.append(f"    }},")
            lines.append(f"    is_active: true;")
            lines.append("")
    
    return "\n".join(lines)

def generate_i18n_translations_batch(parameters: List[Dict], batch_num: int) -> str:
    """Génère les traductions i18n pour un batch"""
    lines = []
    lines.append("-- ============================================================================")
    lines.append(f"-- I18N TRANSLATIONS - PARAMETER BATCH {batch_num}")
    lines.append(f"-- Total: {len(parameters) * 4 * len(LANGUAGES)} translations")
    lines.append("-- ============================================================================\n")
    
    translation_id = (batch_num - 1) * BATCH_SIZE * 4 * len(LANGUAGES) + 1
    
    for param in parameters:
        # 4 types de textes par parameter
        texts = {
            param['i18n_key_name']: param['display_name'],
            param['i18n_key_desc']: param.get('description', param['display_name']),
            param['i18n_key_placeholder']: param.get('placeholder', param['display_name']),
            param['i18n_key_help']: f"Help for {param['display_name']}"
        }
        
        for key_name, text in texts.items():
            for lang_code in LANGUAGES.keys():
                translated = translate_text(text, lang_code)
                
                lines.append(f"CREATE i18n_translation:{translation_id} SET")
                lines.append(f"    i18n_key_id: i18n_key:{key_name},")
                lines.append(f"    language_code: '{lang_code}',")
                lines.append(f"    translated_text: '{escape_surql_string(translated)}',")
                lines.append(f"    is_active: true;")
                lines.append("")
                
                translation_id += 1
    
    return "\n".join(lines)

def generate_all_batches():
    """Génère tous les batches"""
    parameters = load_parameters()
    total = len(parameters)
    num_batches = (total + BATCH_SIZE - 1) // BATCH_SIZE
    
    print("\n" + "="*80)
    print("GENERATION DES BATCHES PARAMETERS")
    print("="*80)
    print(f"Total parameters : {total}")
    print(f"Taille batch : {BATCH_SIZE}")
    print(f"Nombre de batches : {num_batches}")
    print(f"Languages : {', '.join(LANGUAGES.keys())}")
    print("="*80 + "\n")
    
    for batch_num in range(1, num_batches + 1):
        start_idx = (batch_num - 1) * BATCH_SIZE
        end_idx = min(start_idx + BATCH_SIZE, total)
        batch = parameters[start_idx:end_idx]
        
        print(f"Génération batch {batch_num}/{num_batches} ({len(batch)} parameters)...")
        
        # Seeds
        seeds_file = OUTPUT_DIR / f"parameter_batch{batch_num}_seeds.surql"
        seeds_content = generate_seed_batch(batch, batch_num)
        with open(seeds_file, "w", encoding="utf-8") as f:
            f.write(seeds_content)
        
        # I18N Keys
        keys_file = OUTPUT_DIR / f"parameter_batch{batch_num}_i18n_keys.surql"
        keys_content = generate_i18n_keys_batch(batch, batch_num)
        with open(keys_file, "w", encoding="utf-8") as f:
            f.write(keys_content)
        
        # I18N Translations
        trans_file = OUTPUT_DIR / f"parameter_batch{batch_num}_i18n_translations.surql"
        trans_content = generate_i18n_translations_batch(batch, batch_num)
        with open(trans_file, "w", encoding="utf-8") as f:
            f.write(trans_content)
    
    print("\n" + "="*80)
    print("GENERATION TERMINEE")
    print(f"Total fichiers générés : {num_batches * 3}")
    print(f"  - {num_batches} fichiers seeds")
    print(f"  - {num_batches} fichiers i18n keys")
    print(f"  - {num_batches} fichiers i18n translations")
    print(f"Total i18n keys : {total * 4}")
    print(f"Total i18n translations : {total * 4 * len(LANGUAGES)}")
    print("="*80 + "\n")

if __name__ == "__main__":
    generate_all_batches()

