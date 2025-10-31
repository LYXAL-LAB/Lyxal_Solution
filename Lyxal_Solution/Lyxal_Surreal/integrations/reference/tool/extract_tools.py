#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script d'extraction des tools (operations/actions) depuis les fichiers n8n
Crée un mapping JSON: resource -> [tools]
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set

# Chemins
N8N_NODES_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\n8n-master\packages\nodes-base\nodes")
OUTPUT_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\tool")
RESOURCES_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\resource\resources_flat.json")
SERVICES_MAPPING_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\service\services_mapping.json")

def load_resources() -> List[Dict]:
    """Charge la liste des resources"""
    with open(RESOURCES_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def load_services_mapping() -> List[Dict]:
    """Charge le mapping des services"""
    with open(SERVICES_MAPPING_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def extract_operations_from_file(file_path: Path, resource_value: str) -> List[Dict]:
    """
    Extrait les operations d'un fichier .node.ts ou Description.ts
    Cherche la section 'operation' avec les options
    """
    operations = []
    
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        
        # Pattern 1: Recherche de la section "operation" après resource="{resource_value}"
        # Chercher les blocs qui correspondent à ce resource
        resource_pattern = rf"resource:\s*['\"]{re.escape(resource_value)}['\"]"
        resource_matches = list(re.finditer(resource_pattern, content, re.IGNORECASE))
        
        if not resource_matches:
            # Essayer sans le resource (certains nodes ont une seule resource)
            resource_matches = [re.search(r"operation", content, re.IGNORECASE)]
        
        for match in resource_matches:
            if not match:
                continue
            
            # Chercher la section "operation" après le match du resource
            start_pos = match.end() if match else 0
            operation_pattern = r"displayName:\s*['\"]Operation['\"],\s*name:\s*['\"]operation['\"].*?options:\s*\[(.*?)\]"
            operation_match = re.search(operation_pattern, content[start_pos:start_pos+5000], re.DOTALL | re.IGNORECASE)
            
            if operation_match:
                options_block = operation_match.group(1)
                
                # Extraire chaque option: {name: 'Create', value: 'create', action: 'Create a channel', ...}
                option_pattern = r"\{\s*name:\s*['\"]([^'\"]+)['\"]\s*,\s*value:\s*['\"]([^'\"]+)['\"](?:.*?description:\s*['\"]([^'\"]+)['\"])?"
                for option_match in re.finditer(option_pattern, options_block, re.DOTALL):
                    display_name = option_match.group(1).strip()
                    value = option_match.group(2).strip()
                    description = option_match.group(3).strip() if option_match.group(3) else ""
                    
                    # Déterminer le operation_type basé sur le value
                    operation_type = determine_operation_type(value)
                    
                    operations.append({
                        "display_name": display_name,
                        "value": value,
                        "description": description,
                        "operation_type": operation_type
                    })
        
        # Si aucune operation trouvée, créer des operations par défaut basées sur le type de resource
        if not operations:
            operations = create_default_operations(resource_value)
    
    except Exception as e:
        print(f"WARNING: Erreur lecture {file_path.name}: {e}")
    
    return operations

def determine_operation_type(value: str) -> str:
    """Détermine le type d'opération basé sur le nom"""
    value_lower = value.lower()
    
    if any(x in value_lower for x in ["create", "add", "insert", "new", "post"]):
        return "create"
    elif any(x in value_lower for x in ["get", "retrieve", "fetch", "find", "show"]):
        return "read"
    elif any(x in value_lower for x in ["update", "edit", "modify", "change", "patch", "put"]):
        return "update"
    elif any(x in value_lower for x in ["delete", "remove", "destroy"]):
        return "delete"
    elif any(x in value_lower for x in ["list", "getall", "getmany", "search", "query"]):
        return "list"
    elif any(x in value_lower for x in ["search", "find", "query"]):
        return "search"
    elif any(x in value_lower for x in ["upload", "send"]):
        return "upload"
    elif any(x in value_lower for x in ["download", "receive"]):
        return "download"
    elif any(x in value_lower for x in ["execute", "run", "trigger"]):
        return "execute"
    else:
        return "custom"

def create_default_operations(resource_value: str) -> List[Dict]:
    """Crée des operations par défaut si aucune n'est trouvée"""
    # Operations CRUD basiques
    return [
        {
            "display_name": "Get",
            "value": "get",
            "description": f"Get {resource_value}",
            "operation_type": "read"
        },
        {
            "display_name": "Get Many",
            "value": "getMany",
            "description": f"Get many {resource_value}",
            "operation_type": "list"
        }
    ]

def scan_all_resources() -> Dict[str, List[Dict]]:
    """
    Scanne toutes les resources et extrait leurs tools
    Retourne: {resource_slug: [tools]}
    """
    resources = load_resources()
    services_mapping = load_services_mapping()
    
    # Créer un mapping service -> node_file
    service_to_file = {}
    for service in services_mapping:
        service_name = service.get("Service", "").lower()
        node_file = service.get("NodeFile", "")
        service_to_file[service_name] = node_file
    
    resource_tools = {}
    
    stats = {
        "total_resources": len(resources),
        "resources_with_tools": 0,
        "total_tools": 0,
        "resources_without_tools": []
    }
    
    print("Extraction des tools depuis n8n...\n")
    
    for resource in resources:
        resource_slug = resource.get("resource_slug", "")
        service_slug = resource.get("service_slug", "")
        resource_value = resource.get("value", "")
        display_name = resource.get("display_name", "")
        
        # Trouver le fichier node correspondant
        node_file = service_to_file.get(service_slug)
        
        if not node_file or not Path(node_file).exists():
            # Créer des tools par défaut
            tools = create_default_operations(resource_value)
            resource_tools[resource_slug] = tools
            stats["resources_with_tools"] += 1
            stats["total_tools"] += len(tools)
            print(f"OK {display_name:30} -> {len(tools)} tool(s) (defaut)")
            continue
        
        # Extraire les operations du fichier
        node_path = Path(node_file)
        tools = extract_operations_from_file(node_path, resource_value)
        
        if tools:
            resource_tools[resource_slug] = tools
            stats["resources_with_tools"] += 1
            stats["total_tools"] += len(tools)
            print(f"OK {display_name:30} -> {len(tools)} tool(s)")
        else:
            # Créer des tools par défaut
            tools = create_default_operations(resource_value)
            resource_tools[resource_slug] = tools
            stats["resources_with_tools"] += 1
            stats["total_tools"] += len(tools)
            stats["resources_without_tools"].append(resource_slug)
            print(f"OK {display_name:30} -> {len(tools)} tool(s) (defaut)")
    
    print(f"\nSTATISTIQUES:")
    print(f"   - Resources analysees: {stats['total_resources']}")
    print(f"   - Resources avec tools: {stats['resources_with_tools']}")
    print(f"   - Total tools: {stats['total_tools']}")
    if stats['resources_with_tools'] > 0:
        print(f"   - Moyenne: {stats['total_tools'] / stats['resources_with_tools']:.1f} tools/resource\n")
    else:
        print(f"   - Moyenne: 0 tools/resource\n")
    
    return resource_tools

def save_tools_mapping(resource_tools: Dict[str, List[Dict]]):
    """Sauvegarde le mapping des tools en JSON"""
    output_file = OUTPUT_PATH / "tools_mapping.json"
    
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(resource_tools, f, indent=2, ensure_ascii=False)
    
    print(f"OK Mapping sauvegarde: {output_file}")

def generate_tools_flat_list(resource_tools: Dict[str, List[Dict]]) -> List[Dict]:
    """
    Génère une liste plate de tous les tools avec leurs métadonnées
    """
    all_tools = []
    tool_id_counter = 1
    
    for resource_slug, tools in resource_tools.items():
        for tool in tools:
            tool_slug = f"{resource_slug}_{tool['value']}"
            
            all_tools.append({
                "id": tool_id_counter,
                "tool_slug": tool_slug,
                "resource_slug": resource_slug,
                "display_name": tool["display_name"],
                "value": tool["value"],
                "description": tool.get("description", ""),
                "operation_type": tool.get("operation_type", "custom"),
                "i18n_key_name": f"tool_{tool_slug}_name",
                "i18n_key_desc": f"tool_{tool_slug}_desc",
                "i18n_key_tooltip": f"tool_{tool_slug}_tooltip",
                "i18n_key_success": f"tool_{tool_slug}_success",
                "i18n_key_error": f"tool_{tool_slug}_error"
            })
            tool_id_counter += 1
    
    return all_tools

def save_tools_flat_list(all_tools: List[Dict]):
    """Sauvegarde la liste plate en JSON"""
    output_file = OUTPUT_PATH / "tools_flat.json"
    
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_tools, f, indent=2, ensure_ascii=False)
    
    print(f"OK Liste plate sauvegardee: {output_file} ({len(all_tools)} tools)")

def main():
    print("=" * 80)
    print("EXTRACTION DES TOOLS N8N -> LYXAL")
    print("=" * 80)
    print()
    
    # Vérifier que les fichiers sources existent
    if not RESOURCES_PATH.exists():
        print(f"ERROR: Resources introuvable: {RESOURCES_PATH}")
        return
    
    if not SERVICES_MAPPING_PATH.exists():
        print(f"ERROR: Mapping services introuvable: {SERVICES_MAPPING_PATH}")
        return
    
    # Extraire les tools
    resource_tools = scan_all_resources()
    
    # Sauvegarder le mapping
    save_tools_mapping(resource_tools)
    
    # Générer et sauvegarder la liste plate
    all_tools = generate_tools_flat_list(resource_tools)
    save_tools_flat_list(all_tools)
    
    print("\nOK EXTRACTION TERMINEE!")

if __name__ == "__main__":
    main()

