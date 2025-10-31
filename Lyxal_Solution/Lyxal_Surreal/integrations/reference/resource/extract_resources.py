#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script d'extraction des ressources depuis les fichiers .node.ts de n8n
Crée un mapping JSON: service -> [ressources]
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set

# Chemins
N8N_NODES_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\n8n-master\packages\nodes-base\nodes")
OUTPUT_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\resource")
SERVICES_MAPPING_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations\reference\service\services_mapping.json")

def load_services_mapping() -> Dict:
    """Charge le mapping des services existants"""
    with open(SERVICES_MAPPING_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def extract_resources_from_node_file(file_path: Path) -> List[Dict]:
    """
    Extrait les ressources d'un fichier .node.ts
    Cherche la section 'Resource' avec les options
    """
    resources = []
    
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        
        # Pattern 1: Recherche de la section "Resource" avec options
        # Exemple: {displayName: 'Resource', name: 'resource', type: 'options', options: [...]}
        resource_pattern = r"displayName:\s*['\"]Resource['\"],\s*name:\s*['\"]resource['\"],.*?options:\s*\[(.*?)\]"
        match = re.search(resource_pattern, content, re.DOTALL | re.IGNORECASE)
        
        if match:
            options_block = match.group(1)
            
            # Extraire chaque option: {name: 'Channel', value: 'channel'}
            option_pattern = r"\{\s*name:\s*['\"]([^'\"]+)['\"]\s*,\s*value:\s*['\"]([^'\"]+)['\"]"
            for option_match in re.finditer(option_pattern, options_block):
                display_name = option_match.group(1).strip()
                value = option_match.group(2).strip()
                
                resources.append({
                    "display_name": display_name,
                    "value": value
                })
        
        # Pattern 2: Recherche de fichiers de description (ex: ChannelDescription, MessageDescription)
        # Ces fichiers contiennent souvent des ressources
        description_imports = re.findall(
            r"from\s+['\"]\.\/([A-Z]\w+Description)['\"]",
            content
        )
        
        # Si on a des imports de description, on essaie de deviner les ressources
        for desc in description_imports:
            # Exemple: "ChannelDescription" -> "Channel"
            resource_name = desc.replace("Description", "")
            if resource_name and resource_name not in [r["display_name"] for r in resources]:
                resources.append({
                    "display_name": resource_name,
                    "value": resource_name.lower()
                })
    
    except Exception as e:
        print(f"WARNING: Erreur lecture {file_path.name}: {e}")
    
    return resources

def scan_all_services() -> Dict[str, List[Dict]]:
    """
    Scanne tous les services et extrait leurs ressources
    Retourne: {service_slug: [ressources]}
    """
    services = load_services_mapping()
    service_resources = {}
    
    stats = {
        "total_services": len(services),
        "services_with_resources": 0,
        "total_resources": 0,
        "services_without_resources": []
    }
    
    print("Extraction des ressources depuis n8n...\n")
    
    for service in services:
        service_name = service.get("Service", "")
        provider_name = service.get("Provider", "")
        node_file = service.get("NodeFile", "")
        
        if not node_file:
            continue
        
        # Créer le slug du service (lowercase, avec tirets)
        service_slug = service_name.lower().replace(" ", "-")
        
        # Chemin complet du fichier .node.ts
        full_path = Path(node_file)
        
        if not full_path.exists():
            print(f"WARNING: Fichier introuvable: {full_path.name}")
            continue
        
        # Extraire les ressources
        resources = extract_resources_from_node_file(full_path)
        
        if resources:
            service_resources[service_slug] = resources
            stats["services_with_resources"] += 1
            stats["total_resources"] += len(resources)
            print(f"OK {service_name:30} -> {len(resources)} ressource(s)")
        else:
            stats["services_without_resources"].append(service_slug)
            # Certains services n'ont pas de ressources explicites (triggers, etc.)
            # On crée une ressource par défaut
            service_resources[service_slug] = [{
                "display_name": service_name,
                "value": service_slug.replace("-", "_")
            }]
            stats["services_with_resources"] += 1
            stats["total_resources"] += 1
            print(f"OK {service_name:30} -> 1 ressource (defaut)")
    
    print(f"\nSTATISTIQUES:")
    print(f"   - Services analyses: {stats['total_services']}")
    print(f"   - Services avec ressources: {stats['services_with_resources']}")
    print(f"   - Total ressources: {stats['total_resources']}")
    if stats['services_with_resources'] > 0:
        print(f"   - Moyenne: {stats['total_resources'] / stats['services_with_resources']:.1f} ressources/service\n")
    else:
        print(f"   - Moyenne: 0 ressources/service\n")
    
    return service_resources

def save_resources_mapping(service_resources: Dict[str, List[Dict]]):
    """Sauvegarde le mapping des ressources en JSON"""
    output_file = OUTPUT_PATH / "resources_mapping.json"
    
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(service_resources, f, indent=2, ensure_ascii=False)
    
    print(f"OK Mapping sauvegarde: {output_file}")

def generate_resources_flat_list(service_resources: Dict[str, List[Dict]]) -> List[Dict]:
    """
    Génère une liste plate de toutes les ressources avec leurs métadonnées
    """
    all_resources = []
    resource_id_counter = 1
    
    for service_slug, resources in service_resources.items():
        for resource in resources:
            resource_slug = f"{service_slug}_{resource['value']}"
            
            all_resources.append({
                "id": resource_id_counter,
                "resource_slug": resource_slug,
                "service_slug": service_slug,
                "display_name": resource["display_name"],
                "value": resource["value"],
                "i18n_key_name": f"resource_{resource_slug}_name",
                "i18n_key_desc": f"resource_{resource_slug}_desc",
                "i18n_key_tooltip": f"resource_{resource_slug}_tooltip"
            })
            resource_id_counter += 1
    
    return all_resources

def save_resources_flat_list(all_resources: List[Dict]):
    """Sauvegarde la liste plate en JSON"""
    output_file = OUTPUT_PATH / "resources_flat.json"
    
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_resources, f, indent=2, ensure_ascii=False)
    
    print(f"OK Liste plate sauvegardee: {output_file} ({len(all_resources)} ressources)")

def main():
    print("=" * 80)
    print("EXTRACTION DES RESSOURCES N8N -> LYXAL")
    print("=" * 80)
    print()
    
    # Vérifier que le dossier n8n existe
    if not N8N_NODES_PATH.exists():
        print(f"ERROR: Dossier n8n introuvable: {N8N_NODES_PATH}")
        return
    
    # Vérifier que le mapping des services existe
    if not SERVICES_MAPPING_PATH.exists():
        print(f"ERROR: Mapping des services introuvable: {SERVICES_MAPPING_PATH}")
        return
    
    # Extraire les ressources
    service_resources = scan_all_services()
    
    # Sauvegarder le mapping
    save_resources_mapping(service_resources)
    
    # Générer et sauvegarder la liste plate
    all_resources = generate_resources_flat_list(service_resources)
    save_resources_flat_list(all_resources)
    
    print("\nOK EXTRACTION TERMINEE!")

if __name__ == "__main__":
    main()

