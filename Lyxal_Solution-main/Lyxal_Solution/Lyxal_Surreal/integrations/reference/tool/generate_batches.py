#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère les batches de seeds pour la table tool
Crée les fichiers .surql pour seeds, i18n_key et i18n_translation
"""

import json
import math
from pathlib import Path
from typing import List, Dict

# Configuration
INPUT_FILE = Path("tools_flat.json")
OUTPUT_DIR = Path(".")
BATCH_SIZE = 100  # 100 tools par batch
LANGUAGES = ["fr", "en", "it", "de", "es"]

# Mapping operation_type -> HTTP method
OPERATION_TO_METHOD = {
    "create": "POST",
    "read": "GET",
    "update": "PUT",
    "delete": "DELETE",
    "list": "GET",
    "search": "GET",
    "upload": "POST",
    "download": "GET",
    "execute": "POST",
    "custom": "POST"
}

# Mapping operation_type -> couleur
OPERATION_TO_COLOR = {
    "create": "#4CAF50",  # Vert
    "read": "#2196F3",    # Bleu
    "update": "#FF9800",  # Orange
    "delete": "#F44336",  # Rouge
    "list": "#9C27B0",    # Violet
    "search": "#00BCD4",  # Cyan
    "upload": "#8BC34A",  # Vert clair
    "download": "#03A9F4", # Bleu clair
    "execute": "#FFC107",  # Ambre
    "custom": "#607D8B"    # Gris bleu
}

# Traductions génériques par opération
OPERATION_TRANSLATIONS = {
    "create": {
        "fr": {"name": "Créer", "desc": "Créer un nouvel élément", "tooltip": "Créer", "success": "Élément créé avec succès", "error": "Échec de la création"},
        "en": {"name": "Create", "desc": "Create a new item", "tooltip": "Create", "success": "Item created successfully", "error": "Failed to create"},
        "it": {"name": "Crea", "desc": "Crea un nuovo elemento", "tooltip": "Crea", "success": "Elemento creato con successo", "error": "Creazione fallita"},
        "de": {"name": "Erstellen", "desc": "Neues Element erstellen", "tooltip": "Erstellen", "success": "Element erfolgreich erstellt", "error": "Erstellung fehlgeschlagen"},
        "es": {"name": "Crear", "desc": "Crear un nuevo elemento", "tooltip": "Crear", "success": "Elemento creado con éxito", "error": "Error al crear"}
    },
    "read": {
        "fr": {"name": "Lire", "desc": "Lire un élément", "tooltip": "Lire", "success": "Élément récupéré avec succès", "error": "Échec de la lecture"},
        "en": {"name": "Read", "desc": "Read an item", "tooltip": "Read", "success": "Item retrieved successfully", "error": "Failed to read"},
        "it": {"name": "Leggi", "desc": "Leggi un elemento", "tooltip": "Leggi", "success": "Elemento recuperato con successo", "error": "Lettura fallita"},
        "de": {"name": "Lesen", "desc": "Element lesen", "tooltip": "Lesen", "success": "Element erfolgreich abgerufen", "error": "Lesen fehlgeschlagen"},
        "es": {"name": "Leer", "desc": "Leer un elemento", "tooltip": "Leer", "success": "Elemento recuperado con éxito", "error": "Error al leer"}
    },
    "update": {
        "fr": {"name": "Modifier", "desc": "Modifier un élément", "tooltip": "Modifier", "success": "Élément modifié avec succès", "error": "Échec de la modification"},
        "en": {"name": "Update", "desc": "Update an item", "tooltip": "Update", "success": "Item updated successfully", "error": "Failed to update"},
        "it": {"name": "Aggiorna", "desc": "Aggiorna un elemento", "tooltip": "Aggiorna", "success": "Elemento aggiornato con successo", "error": "Aggiornamento fallito"},
        "de": {"name": "Aktualisieren", "desc": "Element aktualisieren", "tooltip": "Aktualisieren", "success": "Element erfolgreich aktualisiert", "error": "Aktualisierung fehlgeschlagen"},
        "es": {"name": "Actualizar", "desc": "Actualizar un elemento", "tooltip": "Actualizar", "success": "Elemento actualizado con éxito", "error": "Error al actualizar"}
    },
    "delete": {
        "fr": {"name": "Supprimer", "desc": "Supprimer un élément", "tooltip": "Supprimer", "success": "Élément supprimé avec succès", "error": "Échec de la suppression"},
        "en": {"name": "Delete", "desc": "Delete an item", "tooltip": "Delete", "success": "Item deleted successfully", "error": "Failed to delete"},
        "it": {"name": "Elimina", "desc": "Elimina un elemento", "tooltip": "Elimina", "success": "Elemento eliminato con successo", "error": "Eliminazione fallita"},
        "de": {"name": "Löschen", "desc": "Element löschen", "tooltip": "Löschen", "success": "Element erfolgreich gelöscht", "error": "Löschen fehlgeschlagen"},
        "es": {"name": "Eliminar", "desc": "Eliminar un elemento", "tooltip": "Eliminar", "success": "Elemento eliminado con éxito", "error": "Error al eliminar"}
    },
    "list": {
        "fr": {"name": "Lister", "desc": "Lister plusieurs éléments", "tooltip": "Lister", "success": "Éléments récupérés avec succès", "error": "Échec de la liste"},
        "en": {"name": "List", "desc": "List multiple items", "tooltip": "List", "success": "Items retrieved successfully", "error": "Failed to list"},
        "it": {"name": "Elenca", "desc": "Elenca più elementi", "tooltip": "Elenca", "success": "Elementi recuperati con successo", "error": "Elenco fallito"},
        "de": {"name": "Auflisten", "desc": "Mehrere Elemente auflisten", "tooltip": "Auflisten", "success": "Elemente erfolgreich abgerufen", "error": "Auflisten fehlgeschlagen"},
        "es": {"name": "Listar", "desc": "Listar múltiples elementos", "tooltip": "Listar", "success": "Elementos recuperados con éxito", "error": "Error al listar"}
    }
}

def load_tools() -> List[Dict]:
    """Charge la liste des tools depuis le JSON"""
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def generate_translation(operation_type: str, display_name: str, lang: str, context: str) -> str:
    """Génère une traduction pour un tool"""
    # Si on a une traduction générique pour ce type d'opération
    if operation_type in OPERATION_TRANSLATIONS:
        return OPERATION_TRANSLATIONS[operation_type][lang][context]
    
    # Sinon, utiliser le display_name tel quel (beaucoup de termes techniques sont universels)
    if context == "name":
        return display_name
    elif context == "desc":
        if lang == "fr":
            return f"Opération {display_name}"
        elif lang == "en":
            return f"{display_name} operation"
        elif lang == "it":
            return f"Operazione {display_name}"
        elif lang == "de":
            return f"{display_name}-Operation"
        elif lang == "es":
            return f"Operación {display_name}"
    elif context == "tooltip":
        return display_name
    elif context == "success":
        if lang == "fr":
            return f"Opération {display_name} réussie"
        elif lang == "en":
            return f"{display_name} operation successful"
        elif lang == "it":
            return f"Operazione {display_name} riuscita"
        elif lang == "de":
            return f"{display_name}-Operation erfolgreich"
        elif lang == "es":
            return f"Operación {display_name} exitosa"
    elif context == "error":
        if lang == "fr":
            return f"Échec de l'opération {display_name}"
        elif lang == "en":
            return f"{display_name} operation failed"
        elif lang == "it":
            return f"Operazione {display_name} fallita"
        elif lang == "de":
            return f"{display_name}-Operation fehlgeschlagen"
        elif lang == "es":
            return f"Operación {display_name} fallida"
    
    return display_name

def generate_seed_batch(tools: List[Dict], batch_num: int) -> str:
    """Génère un fichier .surql de seeds pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: {len(tools)} tools Lyxal\n\n")
    
    for tool in tools:
        resource_slug = tool["resource_slug"]
        tool_slug = tool["tool_slug"]
        display_name = tool["display_name"]
        value = tool["value"]
        operation_type = tool["operation_type"]
        i18n_key_name = tool["i18n_key_name"]
        i18n_key_desc = tool["i18n_key_desc"]
        i18n_key_tooltip = tool["i18n_key_tooltip"]
        i18n_key_success = tool["i18n_key_success"]
        i18n_key_error = tool["i18n_key_error"]
        
        # HTTP method
        http_method = OPERATION_TO_METHOD.get(operation_type, "POST")
        
        # Couleur
        color = OPERATION_TO_COLOR.get(operation_type, "#607D8B")
        
        # is_destructive
        is_destructive = "true" if operation_type == "delete" else "false"
        
        # confirmation_required
        confirmation_required = "true" if operation_type == "delete" else "false"
        
        # success_codes
        success_codes = "[204]" if operation_type == "delete" else "[200, 201]"
        
        surql = f"""CREATE tool:{tool_slug} SET
    identity = {{
        name: "{value}",
        slug: "{tool_slug}",
        display_name_i18n: i18n_key:{i18n_key_name},
        description_i18n: i18n_key:{i18n_key_desc},
        operation_type: "{operation_type}",
        aliases: []
    }},
    presentation = {{
        icon: NONE,
        color: "{color}",
        display_order: {tool['id']},
        tooltip_i18n: i18n_key:{i18n_key_tooltip},
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:{i18n_key_success},
        error_message_i18n: i18n_key:{i18n_key_error},
        confirmation_required: {confirmation_required},
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: {is_destructive}
    }},
    config = {{
        request: {{
            method: "{http_method}",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        }},
        response: {{
            success_codes: {success_codes},
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        }},
        capabilities: {{
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: {confirmation_required}
        }},
        rate_limiting: {{
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }}
    }},
    documentation = NONE,
    metadata = {{
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    }},
    resource_id: resource:{resource_slug},
    is_active: true;

"""
        lines.append(surql)
    
    return "".join(lines)

def generate_i18n_keys_batch(tools: List[Dict], batch_num: int) -> str:
    """Génère les clés i18n pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: Cles i18n pour {len(tools)} tools\n\n")
    
    for tool in tools:
        display_name = tool["display_name"]
        tool_slug = tool["tool_slug"]
        
        lines.append(f"CREATE i18n_key:{tool['i18n_key_name']} SET description = \"Nom du tool {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{tool['i18n_key_desc']} SET description = \"Description du tool {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{tool['i18n_key_tooltip']} SET description = \"Tooltip du tool {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{tool['i18n_key_success']} SET description = \"Message de succes du tool {display_name}\";\n")
        lines.append(f"CREATE i18n_key:{tool['i18n_key_error']} SET description = \"Message d'erreur du tool {display_name}\";\n")
        lines.append("\n")
    
    return "".join(lines)

def generate_i18n_translations_batch(tools: List[Dict], batch_num: int) -> str:
    """Génère les traductions i18n pour un batch"""
    lines = []
    lines.append(f"-- Batch {batch_num}: Traductions (5 langues) pour {len(tools)} tools\n\n")
    
    for tool in tools:
        display_name = tool["display_name"]
        operation_type = tool["operation_type"]
        
        # Pour chaque langue
        for lang in LANGUAGES:
            # Traduction du nom
            name_translation = generate_translation(operation_type, display_name, lang, "name")
            lines.append(f"RELATE i18n_key:{tool['i18n_key_name']}->translation->language:{lang} SET text = \"{name_translation}\";\n")
            
            # Traduction de la description
            desc_translation = generate_translation(operation_type, display_name, lang, "desc")
            lines.append(f"RELATE i18n_key:{tool['i18n_key_desc']}->translation->language:{lang} SET text = \"{desc_translation}\";\n")
            
            # Traduction du tooltip
            tooltip_translation = generate_translation(operation_type, display_name, lang, "tooltip")
            lines.append(f"RELATE i18n_key:{tool['i18n_key_tooltip']}->translation->language:{lang} SET text = \"{tooltip_translation}\";\n")
            
            # Traduction du message de succès
            success_translation = generate_translation(operation_type, display_name, lang, "success")
            lines.append(f"RELATE i18n_key:{tool['i18n_key_success']}->translation->language:{lang} SET text = \"{success_translation}\";\n")
            
            # Traduction du message d'erreur
            error_translation = generate_translation(operation_type, display_name, lang, "error")
            lines.append(f"RELATE i18n_key:{tool['i18n_key_error']}->translation->language:{lang} SET text = \"{error_translation}\";\n")
        
        lines.append("\n")
    
    return "".join(lines)

def main():
    print("=" * 80)
    print("GENERATION DES SEEDS TOOL POUR LYXAL")
    print("=" * 80)
    print()
    
    # Charger les tools
    print("Chargement des tools...")
    tools = load_tools()
    print(f"OK: {len(tools)} tools charges\n")
    
    # Calculer le nombre de batches
    num_batches = math.ceil(len(tools) / BATCH_SIZE)
    print(f"Nombre de batches: {num_batches} ({BATCH_SIZE} tools/batch)\n")
    
    # Générer chaque batch
    for batch_num in range(1, num_batches + 1):
        start_idx = (batch_num - 1) * BATCH_SIZE
        end_idx = min(start_idx + BATCH_SIZE, len(tools))
        batch_tools = tools[start_idx:end_idx]
        
        print(f"Batch {batch_num}/{num_batches}: {len(batch_tools)} tools...")
        
        # 1. Seeds
        seeds_content = generate_seed_batch(batch_tools, batch_num)
        seeds_file = OUTPUT_DIR / f"tool_batch{batch_num}_seeds.surql"
        with open(seeds_file, "w", encoding="utf-8") as f:
            f.write(seeds_content)
        print(f"  OK: {seeds_file.name}")
        
        # 2. i18n keys
        i18n_keys_content = generate_i18n_keys_batch(batch_tools, batch_num)
        i18n_keys_file = OUTPUT_DIR / f"tool_batch{batch_num}_i18n_keys.surql"
        with open(i18n_keys_file, "w", encoding="utf-8") as f:
            f.write(i18n_keys_content)
        print(f"  OK: {i18n_keys_file.name}")
        
        # 3. i18n translations
        i18n_translations_content = generate_i18n_translations_batch(batch_tools, batch_num)
        i18n_translations_file = OUTPUT_DIR / f"tool_batch{batch_num}_i18n_translations.surql"
        with open(i18n_translations_file, "w", encoding="utf-8") as f:
            f.write(i18n_translations_content)
        print(f"  OK: {i18n_translations_file.name}\n")
    
    # Statistiques finales
    total_seeds = len(tools)
    total_i18n_keys = len(tools) * 5  # name, desc, tooltip, success, error
    total_translations = total_i18n_keys * len(LANGUAGES)
    total_files = num_batches * 3  # seeds, keys, translations
    
    print("=" * 80)
    print("GENERATION TERMINEE!")
    print("=" * 80)
    print(f"Batches: {num_batches}")
    print(f"Fichiers: {total_files}")
    print(f"Seeds tools: {total_seeds}")
    print(f"Cles i18n: {total_i18n_keys}")
    print(f"Traductions: {total_translations} ({len(LANGUAGES)} langues)")
    print()

if __name__ == "__main__":
    main()

