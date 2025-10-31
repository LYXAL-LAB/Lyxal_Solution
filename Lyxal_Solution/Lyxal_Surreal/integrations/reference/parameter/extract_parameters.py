#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EXTRACTION DES PARAMETERS DEPUIS N8N
Extrait 1:1 les parameters depuis les fichiers Description.ts
"""

import json
import re
from pathlib import Path
from typing import List, Dict, Optional

# Chemins
N8N_NODES_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\n8n-master\packages\nodes-base\nodes")
BASE_DIR = Path(__file__).parent
TOOLS_PATH = BASE_DIR.parent / "tool" / "tools_flat.json"
RESOURCES_PATH = BASE_DIR.parent / "resource" / "resources_flat.json"
SERVICES_MAPPING_PATH = BASE_DIR.parent / "service" / "services_mapping.json"
OUTPUT_PATH = BASE_DIR / "parameters_flat.json"

def load_tools() -> List[Dict]:
    """Charge la liste des tools"""
    with open(TOOLS_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def load_resources() -> List[Dict]:
    """Charge la liste des resources"""
    with open(RESOURCES_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def load_services_mapping() -> List[Dict]:
    """Charge le mapping des services"""
    with open(SERVICES_MAPPING_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def slugify(text: str) -> str:
    """Convertit un texte en slug"""
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '_', text)
    text = re.sub(r'_+', '_', text)
    return text.strip('_')

def extract_parameters_from_file(file_path: Path, resource_value: str, operation_value: str) -> List[Dict]:
    """
    Extrait les parameters d'un fichier Description.ts
    pour un resource et une operation spécifiques
    """
    parameters = []
    
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        
        # Chercher l'export des fields (ex: export const channelFields: INodeProperties[])
        fields_pattern = r"export\s+const\s+\w*Fields:\s*INodeProperties\[\]\s*=\s*\[(.*?)\];"
        fields_match = re.search(fields_pattern, content, re.DOTALL)
        
        if not fields_match:
            return parameters
        
        fields_content = fields_match.group(1)
        
        # Parser les objets INodeProperties
        # Chercher les objets qui correspondent à l'operation
        obj_pattern = r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}'
        obj_matches = re.finditer(obj_pattern, fields_content, re.DOTALL)
        
        for obj_match in obj_matches:
            obj_str = obj_match.group(0)
            
            # Vérifier si ce champ correspond à notre operation
            # Chercher displayOptions -> operation: ['value']
            if f"operation: ['{operation_value}']" in obj_str or \
               f'operation: ["{operation_value}"]' in obj_str or \
               'displayOptions' not in obj_str:  # Pas de condition = toujours affiché
                
                param = parse_parameter(obj_str)
                if param:
                    parameters.append(param)
    
    except Exception as e:
        print(f"WARNING: Erreur lecture {file_path.name}: {e}")
    
    return parameters

def parse_parameter(obj_str: str) -> Optional[Dict]:
    """Parse un objet INodeProperties pour en extraire les infos"""
    param = {}
    
    # Ignorer les champs 'resource' et 'operation' (méta-champs)
    name_match = re.search(r"name:\s*['\"]([^'\"]+)['\"]", obj_str)
    if not name_match:
        return None
    
    name = name_match.group(1)
    if name in ['resource', 'operation']:
        return None
    
    param['name'] = name
    
    # displayName
    display_match = re.search(r"displayName:\s*['\"]([^'\"]+)['\"]", obj_str)
    if display_match:
        param['displayName'] = display_match.group(1)
    else:
        param['displayName'] = name
    
    # type
    type_match = re.search(r"type:\s*['\"]([^'\"]+)['\"]", obj_str)
    if type_match:
        param['type'] = type_match.group(1)
    else:
        param['type'] = 'string'
    
    # description
    desc_match = re.search(r"description:\s*['\"]([^'\"]+)['\"]", obj_str)
    if desc_match:
        param['description'] = desc_match.group(1)
    
    # placeholder
    placeholder_match = re.search(r"placeholder:\s*['\"]([^'\"]+)['\"]", obj_str)
    if placeholder_match:
        param['placeholder'] = placeholder_match.group(1)
    
    # required
    if re.search(r"required:\s*true", obj_str):
        param['required'] = True
    else:
        param['required'] = False
    
    # default
    default_match = re.search(r"default:\s*(['\"]?[^,}\]]+['\"]?)", obj_str)
    if default_match:
        default_val = default_match.group(1).strip()
        # Nettoie les quotes et ignore les valeurs vides
        default_val = re.sub(r"^['\"]|['\"]$", "", default_val)
        if default_val not in ['', 'undefined', 'null', '{', '[']:
            param['default'] = default_val
    
    # Options (pour select/multiOptions)
    if 'options:' in obj_str:
        param['has_options'] = True
    
    # typeOptions
    if 'typeOptions:' in obj_str:
        param['has_type_options'] = True
    
    # displayOptions (conditions d'affichage)
    if 'displayOptions:' in obj_str:
        param['has_display_options'] = True
    
    return param

def scan_all_parameters() -> List[Dict]:
    """
    Scanne tous les tools et extrait leurs parameters
    """
    tools = load_tools()
    resources = load_resources()
    services = load_services_mapping()
    
    # Créer des mappings pour accès rapide
    resource_map = {r['resource_slug']: r for r in resources}
    service_map = {slugify(s['Service']): s for s in services}
    
    all_parameters = []
    param_counter = 1
    
    print("\n" + "="*80)
    print("EXTRACTION DES PARAMETERS N8N -> LYXAL")
    print("="*80 + "\n")
    
    for tool in tools:
        tool_slug = tool['tool_slug']
        tool_name = tool['display_name']
        operation_value = tool['value']
        resource_slug = tool['resource_slug']
        
        # Récupère la resource
        resource = resource_map.get(resource_slug)
        if not resource:
            continue
        
        resource_value = resource['value']
        service_slug = resource['service_slug']
        
        # Récupère le service
        service = service_map.get(service_slug)
        if not service:
            continue
        
        # Trouve le fichier Description
        node_file = service.get('NodeFile', '')
        if not node_file:
            continue
        
        node_path = Path(node_file)
        if not node_path.exists():
            continue
        
        # Cherche les fichiers Description.ts dans le même dossier
        node_dir = node_path.parent
        desc_files = list(node_dir.glob("*Description.ts"))
        
        if not desc_files:
            continue
        
        # Extraire les parameters de tous les fichiers Description
        all_params_for_tool = []
        for desc_file in desc_files:
            params = extract_parameters_from_file(desc_file, resource_value, operation_value)
            all_params_for_tool.extend(params)
        
        if not all_params_for_tool:
            continue
        
        print(f"OK {service_slug:25} | {resource_value:20} | {operation_value:20} -> {len(all_params_for_tool):2} parameters")
        
        # Crée les records de parameters
        for idx, param in enumerate(all_params_for_tool, 1):
            param_slug = f"{tool_slug}_{param['name']}"
            
            param_record = {
                'id': param_counter,
                'parameter_slug': param_slug,
                'tool_slug': tool_slug,
                'parameter_name': param['name'],
                'display_name': param['displayName'],
                'description': param.get('description', ''),
                'parameter_type': param['type'],
                'is_required': param['required'],
                'default_value': param.get('default'),
                'placeholder': param.get('placeholder'),
                'display_order': idx,
                'has_options': param.get('has_options', False),
                'has_display_conditions': param.get('has_display_options', False),
                'has_type_options': param.get('has_type_options', False),
                'i18n_key_name': f"parameter_{param_slug}_name",
                'i18n_key_desc': f"parameter_{param_slug}_desc",
                'i18n_key_placeholder': f"parameter_{param_slug}_placeholder",
                'i18n_key_help': f"parameter_{param_slug}_help"
            }
            
            all_parameters.append(param_record)
            param_counter += 1
    
    return all_parameters

def save_parameters(parameters: List[Dict]):
    """Sauvegarde les parameters en JSON"""
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(parameters, f, indent=2, ensure_ascii=False)
    
    print("\n" + "="*80)
    print(f"EXTRACTION TERMINEE")
    print(f"Total parameters extraits : {len(parameters)}")
    print(f"Fichier de sortie : {OUTPUT_PATH}")
    print("="*80 + "\n")

def main():
    """Fonction principale"""
    parameters = scan_all_parameters()
    save_parameters(parameters)

if __name__ == "__main__":
    main()
