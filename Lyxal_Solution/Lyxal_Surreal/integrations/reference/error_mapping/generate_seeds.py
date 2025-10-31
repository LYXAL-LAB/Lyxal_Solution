#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GENERATION DES SEEDS POUR ERROR_MAPPING
Génère les fichiers .surql pour les seeds, i18n keys et translations
À partir des données EXTRAITES depuis n8n
"""

import json
from pathlib import Path
from typing import List, Dict

# Chemins
BASE_DIR = Path(__file__).parent
INPUT_PATH = BASE_DIR / "error_mappings_extracted.json"
OUTPUT_DIR = BASE_DIR

# Langues
LANGUAGES = {
    'fr': 'Français',
    'en': 'English',
    'it': 'Italiano',
    'de': 'Deutsch',
    'es': 'Español'
}

def load_error_mappings() -> List[Dict]:
    """Charge les error mappings extraits depuis n8n"""
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def slugify(text: str) -> str:
    """Convertit un texte en slug"""
    import re
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '_', text)
    text = re.sub(r'_+', '_', text)
    return text.strip('_')

def escape_surql_string(text: str) -> str:
    """Échappe une chaîne pour SurrealQL"""
    if not text:
        return ""
    text = text.replace("\\", "\\\\")
    text = text.replace('"', '\\"')
    text = text.replace("'", "\\'")
    text = text.replace("\n", "\\n")
    text = text.replace("\r", "\\r")
    return text

def translate_text(text: str, lang: str) -> str:
    """Traduit un texte (ici on garde l'anglais pour simplifier)"""
    return text

def categorize_error(error: Dict) -> str:
    """Catégorise une erreur basée sur son message"""
    message = error['message'].lower()
    
    if error.get('http_code'):
        code = error['http_code']
        if code == 401:
            return 'auth'
        elif code == 403:
            return 'permission'
        elif code == 404:
            return 'not_found'
        elif code == 429:
            return 'rate_limit'
        elif code >= 500:
            return 'server'
    
    if 'not a valid' in message or 'invalid' in message:
        return 'validation'
    
    return 'other'

def determine_severity(error: Dict) -> str:
    """Détermine la sévérité d'une erreur"""
    http_code = error.get('http_code')
    
    if http_code:
        if http_code >= 500:
            return 'critical' if http_code == 500 else 'error'
        elif http_code == 429:
            return 'warning'
        elif http_code in [401, 403]:
            return 'error'
        elif http_code == 404:
            return 'warning'
    
    return 'error'

def generate_seeds() -> str:
    """Génère le fichier seeds"""
    errors = load_error_mappings()
    lines = []
    
    lines.append("-- ============================================================================")
    lines.append("-- ERROR_MAPPING SEEDS")
    lines.append(f"-- Total: {len(errors)} error mappings (extracted from n8n)")
    lines.append("-- ============================================================================\n")
    
    for idx, error in enumerate(errors, 1):
        # Créer un slug unique
        service_slug = error['service_slug']
        error_type = error.get('error_type', 'validation')
        http_code = error.get('http_code', 0)
        message_slug = slugify(error['message'][:50])
        
        slug = f"{service_slug}_{error_type}_{http_code or message_slug}"
        
        # Éviter les doublons de slug (ajouter un numéro)
        base_slug = slug
        counter = 1
        # On simplifie ici, en prod il faudrait tracker les slugs utilisés
        if len(slug) > 50:
            slug = slug[:50]
        
        service_ref = f"service:{service_slug}"
        http_code_str = str(http_code) if http_code else 'NONE'
        error_code = error.get('error_code')
        error_code_str = f"'{error_code}'" if error_code else 'NONE'
        
        category = categorize_error(error)
        severity = determine_severity(error)
        
        is_retryable = http_code in [429, 500, 502, 503, 504] if http_code else False
        
        lines.append(f"CREATE error_mapping:{slug}_{idx} SET")
        lines.append(f"    identity = {{")
        lines.append(f"        http_code: {http_code_str},")
        lines.append(f"        error_code: {error_code_str},")
        lines.append(f"        error_category: '{category}',")
        lines.append(f"        service_id: {service_ref},")
        lines.append(f"        tool_id: NONE")
        lines.append(f"    }},")
        lines.append(f"    presentation = {{")
        lines.append(f"        user_message_i18n: i18n_key:error_{slug}_{idx}_user_msg,")
        lines.append(f"        technical_message_i18n: i18n_key:error_{slug}_{idx}_tech_msg,")
        lines.append(f"        severity: '{severity}',")
        lines.append(f"        icon: NONE,")
        lines.append(f"        color: NONE")
        lines.append(f"    }},")
        lines.append(f"    config = {{")
        lines.append(f"        is_retryable: {str(is_retryable).lower()},")
        lines.append(f"        retry_after_seconds: NONE,")
        lines.append(f"        max_retries: {'3' if is_retryable else '0'},")
        lines.append(f"        backoff_strategy: {'exponential' if is_retryable else 'NONE'},")
        lines.append(f"        should_log: true,")
        lines.append(f"        should_notify_admin: {str(severity == 'critical').lower()}")
        lines.append(f"    }},")
        lines.append(f"    suggested_action = {{")
        lines.append(f"        action_message_i18n: i18n_key:error_{slug}_{idx}_action,")
        lines.append(f"        action_type: {'check_input' if category == 'validation' else 'NONE'},")
        lines.append(f"        help_url: NONE,")
        lines.append(f"        support_contact: NONE")
        lines.append(f"    }},")
        lines.append(f"    documentation = {{")
        lines.append(f"        description_i18n: NONE,")
        lines.append(f"        common_causes: NONE,")
        lines.append(f"        example_request: NONE,")
        lines.append(f"        example_response: NONE")
        lines.append(f"    }},")
        lines.append(f"    metadata = {{")
        lines.append(f"        created_at: time::now(),")
        lines.append(f"        updated_at: time::now(),")
        lines.append(f"        created_by: NONE,")
        lines.append(f"        updated_by: NONE,")
        lines.append(f"        version: 1,")
        lines.append(f"        etag: rand::uuid::v7(),")
        lines.append(f"        tags: ['{error_type}', '{category}'],")
        lines.append(f"        custom_data: {{")
        lines.append(f"            source_file: '{escape_surql_string(error.get('source_file', ''))}'")
        lines.append(f"        }}")
        lines.append(f"    }},")
        lines.append(f"    is_active: true;")
        lines.append("")
    
    return "\n".join(lines)

def generate_i18n_keys() -> str:
    """Génère les clés i18n"""
    errors = load_error_mappings()
    lines = []
    
    lines.append("-- ============================================================================")
    lines.append("-- I18N KEYS - ERROR_MAPPING")
    lines.append(f"-- Total: {len(errors) * 3} keys (3 per error mapping)")
    lines.append("-- ============================================================================\n")
    
    for idx, error in enumerate(errors, 1):
        service_slug = error['service_slug']
        error_type = error.get('error_type', 'validation')
        http_code = error.get('http_code', 0)
        message_slug = slugify(error['message'][:50])
        
        slug = f"{service_slug}_{error_type}_{http_code or message_slug}"
        if len(slug) > 50:
            slug = slug[:50]
        
        # 3 clés par error mapping: user_msg, tech_msg, action
        keys = [
            (f"error_{slug}_{idx}_user_msg", f"User message for {error['message'][:50]}"),
            (f"error_{slug}_{idx}_tech_msg", f"Technical message for {error['message'][:50]}"),
            (f"error_{slug}_{idx}_action", f"Action message for {error['message'][:50]}")
        ]
        
        for key_name, key_desc in keys:
            lines.append(f"CREATE i18n_key:{key_name} SET")
            lines.append(f"    identity = {{")
            lines.append(f"        key: '{key_name}',")
            lines.append(f"        description: '{escape_surql_string(key_desc)}',")
            lines.append(f"        context: 'error_mapping',")
            lines.append(f"        category: 'error'")
            lines.append(f"    }},")
            lines.append(f"    metadata = {{")
            lines.append(f"        created_at: time::now(),")
            lines.append(f"        updated_at: time::now(),")
            lines.append(f"        version: 1")
            lines.append(f"    }},")
            lines.append(f"    is_active: true;")
            lines.append("")
    
    return "\n".join(lines)

def generate_i18n_translations() -> str:
    """Génère les traductions i18n"""
    errors = load_error_mappings()
    lines = []
    
    lines.append("-- ============================================================================")
    lines.append("-- I18N TRANSLATIONS - ERROR_MAPPING")
    lines.append(f"-- Total: {len(errors) * 3 * len(LANGUAGES)} translations")
    lines.append("-- ============================================================================\n")
    
    translation_id = 1
    
    for idx, error in enumerate(errors, 1):
        service_slug = error['service_slug']
        error_type = error.get('error_type', 'validation')
        http_code = error.get('http_code', 0)
        message_slug = slugify(error['message'][:50])
        
        slug = f"{service_slug}_{error_type}_{http_code or message_slug}"
        if len(slug) > 50:
            slug = slug[:50]
        
        # 3 types de textes par error mapping
        texts = {
            f"error_{slug}_{idx}_user_msg": error['message'],
            f"error_{slug}_{idx}_tech_msg": f"Source: {error.get('source_file', 'unknown')}",
            f"error_{slug}_{idx}_action": f"Please verify your input and try again."
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

def generate_all():
    """Génère tous les fichiers"""
    errors = load_error_mappings()
    
    print("\n" + "="*80)
    print("GENERATION DES SEEDS ERROR_MAPPING")
    print("="*80)
    print(f"Total error mappings : {len(errors)}")
    print(f"Languages : {', '.join(LANGUAGES.keys())}")
    print("="*80 + "\n")
    
    # Seeds
    print("Génération des seeds...")
    seeds_file = OUTPUT_DIR / "error_mapping_seeds.surql"
    seeds_content = generate_seeds()
    with open(seeds_file, "w", encoding="utf-8") as f:
        f.write(seeds_content)
    print(f"  OK {seeds_file.name}")
    
    # I18N Keys
    print("Génération des clés i18n...")
    keys_file = OUTPUT_DIR / "error_mapping_i18n_keys.surql"
    keys_content = generate_i18n_keys()
    with open(keys_file, "w", encoding="utf-8") as f:
        f.write(keys_content)
    print(f"  OK {keys_file.name}")
    
    # I18N Translations
    print("Génération des traductions i18n...")
    trans_file = OUTPUT_DIR / "error_mapping_i18n_translations.surql"
    trans_content = generate_i18n_translations()
    with open(trans_file, "w", encoding="utf-8") as f:
        f.write(trans_content)
    print(f"  OK {trans_file.name}")
    
    print("\n" + "="*80)
    print("GENERATION TERMINEE")
    print(f"Total fichiers générés : 3")
    print(f"Total i18n keys : {len(errors) * 3}")
    print(f"Total i18n translations : {len(errors) * 3 * len(LANGUAGES)}")
    print("="*80 + "\n")

if __name__ == "__main__":
    generate_all()
