#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère les batches de seeds pour la table resource
Crée les fichiers .surql pour seeds, i18n_key et i18n_translation
"""

import json
import math
from pathlib import Path
from typing import List, Dict

# Configuration
INPUT_FILE = Path("resources_flat.json")
OUTPUT_DIR = Path(".")
BATCH_SIZE = 50  # 50 ressources par batch
LANGUAGES = ["fr", "en", "it", "de", "es"]

# Traductions génériques par langue
GENERIC_TRANSLATIONS = {
    # Exemples de noms communs
    "user": {
        "fr": "Utilisateur",
        "en": "User",
        "it": "Utente",
        "de": "Benutzer",
        "es": "Usuario"
    },
    "message": {
        "fr": "Message",
        "en": "Message",
        "it": "Messaggio",
        "de": "Nachricht",
        "es": "Mensaje"
    },
    "file": {
        "fr": "Fichier",
        "en": "File",
        "it": "File",
        "de": "Datei",
        "es": "Archivo"
    },
    "channel": {
        "fr": "Canal",
        "en": "Channel",
        "it": "Canale",
        "de": "Kanal",
        "es": "Canal"
    },
    "event": {
        "fr": "Événement",
        "en": "Event",
        "it": "Evento",
        "de": "Ereignis",
        "es": "Evento"
    }
}

def load_resources() -> List[Dict]:
    """Charge la liste des ressources depuis le JSON"""
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def slugify(text: str) -> str:
    """Convertit un texte en slug"""
    return text.lower().replace(" ", "_").replace("-", "_")

def generate_translation(display_name: str, lang: str, context: str = "name") -> str:
    """
    Génère une traduction basique pour un nom de ressource
    context: "name", "desc", "tooltip"
    """
    lower_name = display_name.lower()
    
    # Si on a une traduction générique, l'utiliser
    for key, translations in GENERIC_TRANSLATIONS.items():
        if key in lower_name:
            base_translation = translations.get(lang, display_name)
            if context == "desc":
                if lang == "fr":
                    return f"Ressource représentant {base_translation.lower()}"
                elif lang == "en":
                    return f"Resource representing {base_translation.lower()}"
                elif lang == "it":
                    return f"Risorsa che rappresenta {base_translation.lower()}"
                elif lang == "de":
                    return f"Ressource, die {base_translation} darstellt"
                elif lang == "es":
                    return f"Recurso que representa {base_translation.lower()}"
            elif context == "tooltip":
                if lang == "fr":
                    return f"Gérer les {base_translation.lower()}s"
                elif lang == "en":
                    return f"Manage {base_translation.lower()}s"
                elif lang == "it":
                    return f"Gestisci {base_translation.lower()}"
                elif lang == "de":
                    return f"{base_translation} verwalten"
                elif lang == "es":
                    return f"Gestionar {base_translation.lower()}s"
            return base_translation
    
    # Sinon, garder le nom original (beaucoup de termes techniques sont universels)
    if context == "name":
        return display_name
    elif context == "desc":
        if lang == "fr":
            return f"Ressource {display_name}"
        elif lang == "en":
            return f"{display_name} resource"
        elif lang == "it":
            return f"Risorsa {display_name}"
        elif lang == "de":
            return f"{display_name}-Ressource"
        elif lang == "es":
            return f"Recurso {display_name}"
    elif context == "tooltip":
        if lang == "fr":
            return f"Opérations sur {display_name}"
        elif lang == "en":
            return f"Operations on {display_name}"
        elif lang == "it":
            return f"Operazioni su {display_name}"
        elif lang == "de":
            return f"Operationen auf {display_name}"
        elif lang == "es":
            return f"Operaciones en {display_name}"
    
    return display_name

def generate_seed_batch(resources: List[Dict], batch_num: int) -> str:
    """Génère un fichier .surql de seeds pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: {len(resources)} ressources Lyxal\n\n")
    
    for resource in resources:
        service_slug = resource["service_slug"]
        resource_slug = resource["resource_slug"]
        display_name = resource["display_name"]
        value = resource["value"]
        i18n_key_name = resource["i18n_key_name"]
        i18n_key_desc = resource["i18n_key_desc"]
        i18n_key_tooltip = resource["i18n_key_tooltip"]
        
        # Déterminer les capacités par défaut basées sur le nom de la ressource
        supports_create = True
        supports_read = True
        supports_update = True
        supports_delete = False  # Par défaut, pas de suppression
        supports_list = True
        supports_search = False
        
        # Quelques heuristiques
        lower_name = display_name.lower()
        if "trigger" in lower_name or "webhook" in lower_name:
            supports_create = False
            supports_update = False
        if "log" in lower_name or "history" in lower_name:
            supports_create = False
            supports_update = False
            supports_delete = False
            supports_search = True
        
        surql = f"""CREATE resource:{resource_slug} SET
    identity = {{
        name: "{value}",
        slug: "{resource_slug}",
        display_name_i18n: i18n_key:{i18n_key_name},
        description_i18n: i18n_key:{i18n_key_desc},
        aliases: []
    }},
    presentation = {{
        icon: NONE,
        color: NONE,
        display_order: {resource['id']},
        tooltip_i18n: i18n_key:{i18n_key_tooltip},
        badge_text: NONE,
        badge_color: NONE
    }},
    config = {{
        operation_types: {{
            supports_create: {str(supports_create).lower()},
            supports_read: {str(supports_read).lower()},
            supports_update: {str(supports_update).lower()},
            supports_delete: {str(supports_delete).lower()},
            supports_list: {str(supports_list).lower()},
            supports_search: {str(supports_search).lower()}
        }},
        capabilities: {{
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        }},
        api: {{
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }}
    }},
    documentation = NONE,
    metadata = {{
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    }},
    service_id: service:{service_slug},
    is_active: true;

"""
        lines.append(surql)
    
    return "".join(lines)

def generate_i18n_keys_batch(resources: List[Dict], batch_num: int) -> str:
    """Génère les clés i18n pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: Cles i18n pour {len(resources)} ressources\n\n")
    
    for resource in resources:
        i18n_key_name = resource["i18n_key_name"]
        i18n_key_desc = resource["i18n_key_desc"]
        i18n_key_tooltip = resource["i18n_key_tooltip"]
        display_name = resource["display_name"]
        resource_slug = resource["resource_slug"]
        
        lines.append(f"CREATE i18n_key:{i18n_key_name} SET description = \"Nom de la ressource {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{i18n_key_desc} SET description = \"Description de la ressource {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{i18n_key_tooltip} SET description = \"Tooltip de la ressource {display_name}\";\n")
        lines.append("\n")
    
    return "".join(lines)

def generate_i18n_translations_batch(resources: List[Dict], batch_num: int) -> str:
    """Génère les traductions i18n pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: Traductions (5 langues) pour {len(resources)} ressources\n\n")
    
    for resource in resources:
        i18n_key_name = resource["i18n_key_name"]
        i18n_key_desc = resource["i18n_key_desc"]
        i18n_key_tooltip = resource["i18n_key_tooltip"]
        display_name = resource["display_name"]
        
        # Pour chaque langue
        for lang in LANGUAGES:
            # Traduction du nom
            name_translation = generate_translation(display_name, lang, "name")
            lines.append(f"RELATE i18n_key:{i18n_key_name}->translation->language:{lang} SET text = \"{name_translation}\";\n")
            
            # Traduction de la description
            desc_translation = generate_translation(display_name, lang, "desc")
            lines.append(f"RELATE i18n_key:{i18n_key_desc}->translation->language:{lang} SET text = \"{desc_translation}\";\n")
            
            # Traduction du tooltip
            tooltip_translation = generate_translation(display_name, lang, "tooltip")
            lines.append(f"RELATE i18n_key:{i18n_key_tooltip}->translation->language:{lang} SET text = \"{tooltip_translation}\";\n")
        
        lines.append("\n")
    
    return "".join(lines)

def main():
    print("=" * 80)
    print("GENERATION DES SEEDS RESOURCE POUR LYXAL")
    print("=" * 80)
    print()
    
    # Charger les ressources
    print("Chargement des ressources...")
    resources = load_resources()
    print(f"OK: {len(resources)} ressources chargees\n")
    
    # Calculer le nombre de batches
    num_batches = math.ceil(len(resources) / BATCH_SIZE)
    print(f"Nombre de batches: {num_batches} ({BATCH_SIZE} ressources/batch)\n")
    
    # Générer chaque batch
    for batch_num in range(1, num_batches + 1):
        start_idx = (batch_num - 1) * BATCH_SIZE
        end_idx = min(start_idx + BATCH_SIZE, len(resources))
        batch_resources = resources[start_idx:end_idx]
        
        print(f"Batch {batch_num}/{num_batches}: {len(batch_resources)} ressources...")
        
        # 1. Seeds
        seeds_content = generate_seed_batch(batch_resources, batch_num)
        seeds_file = OUTPUT_DIR / f"resource_batch{batch_num}_seeds.surql"
        with open(seeds_file, "w", encoding="utf-8") as f:
            f.write(seeds_content)
        print(f"  OK: {seeds_file.name}")
        
        # 2. i18n keys
        i18n_keys_content = generate_i18n_keys_batch(batch_resources, batch_num)
        i18n_keys_file = OUTPUT_DIR / f"resource_batch{batch_num}_i18n_keys.surql"
        with open(i18n_keys_file, "w", encoding="utf-8") as f:
            f.write(i18n_keys_content)
        print(f"  OK: {i18n_keys_file.name}")
        
        # 3. i18n translations
        i18n_translations_content = generate_i18n_translations_batch(batch_resources, batch_num)
        i18n_translations_file = OUTPUT_DIR / f"resource_batch{batch_num}_i18n_translations.surql"
        with open(i18n_translations_file, "w", encoding="utf-8") as f:
            f.write(i18n_translations_content)
        print(f"  OK: {i18n_translations_file.name}\n")
    
    # Statistiques finales
    total_seeds = len(resources)
    total_i18n_keys = len(resources) * 3  # name, desc, tooltip
    total_translations = total_i18n_keys * len(LANGUAGES)
    total_files = num_batches * 3  # seeds, keys, translations
    
    print("=" * 80)
    print("GENERATION TERMINEE!")
    print("=" * 80)
    print(f"Batches: {num_batches}")
    print(f"Fichiers: {total_files}")
    print(f"Seeds ressources: {total_seeds}")
    print(f"Cles i18n: {total_i18n_keys}")
    print(f"Traductions: {total_translations} ({len(LANGUAGES)} langues)")
    print()

if __name__ == "__main__":
    main()

