#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EXTRACTION COMPLETE DES ERROR MESSAGES DEPUIS N8N
Version 2 - Scan complet et exhaustif
"""

import json
import re
from pathlib import Path
from typing import List, Dict, Set

# Chemins
N8N_NODES_PATH = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\n8n-master\packages\nodes-base\nodes")
BASE_DIR = Path(__file__).parent
SERVICES_PATH = BASE_DIR.parent / "service" / "services_mapping.json"
OUTPUT_PATH = BASE_DIR / "error_mappings_extracted.json"

def load_services() -> List[Dict]:
    """Charge le mapping des services"""
    with open(SERVICES_PATH, "r", encoding="utf-8-sig") as f:
        return json.load(f)

def slugify(text: str) -> str:
    """Convertit un texte en slug"""
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '_', text)
    return text.strip('_')

def scan_service_directory(service_dir: Path) -> Dict[str, Set[str]]:
    """
    Scanne TOUT le dossier d'un service pour extraire TOUTES les erreurs
    Retourne un dict avec les types d'erreurs et les messages uniques
    """
    results = {
        'validation': set(),  # errorMessage dans Description.ts
        'operation': set(),   # NodeOperationError
        'constants': set(),   # ERROR_MESSAGES
        'http': {}           # errorMapping {code: message}
    }
    
    # Scanner TOUS les fichiers .ts (sauf tests)
    for ts_file in service_dir.rglob("*.ts"):
        if 'test' in ts_file.name.lower():
            continue
        
        try:
            content = ts_file.read_text(encoding="utf-8", errors="ignore")
            
            # 1. errorMessage: 'text' (validation)
            for match in re.finditer(r"errorMessage:\s*['\"]([^'\"]+)['\"]", content):
                message = match.group(1).strip()
                if message:
                    results['validation'].add(message)
            
            # 2. throw new NodeOperationError(this.getNode(), 'message'
            pattern = r"throw\s+new\s+NodeOperationError\s*\(\s*this\.getNode\(\)\s*,\s*['\"]([^'\"]+)['\"]"
            for match in re.finditer(pattern, content, re.DOTALL):
                message = match.group(1).strip()
                if len(message) > 10 and '${' not in message:
                    results['operation'].add(message)
            
            # 2b. throw new NodeApiError(this.getNode(), { message: 'text', ... })
            api_pattern = r"NodeApiError\s*\([^,]+,\s*\{[^}]*message:\s*['\"]([^'\"]+)['\"]"
            for match in re.finditer(api_pattern, content, re.DOTALL):
                message = match.group(1).strip()
                if len(message) > 10 and '${' not in message:
                    results['operation'].add(message)
            
            # 2c. throw new ApplicationError('message', ...)
            app_pattern = r"new\s+ApplicationError\s*\(\s*['\"]([^'\"]+)['\"]"
            for match in re.finditer(app_pattern, content):
                message = match.group(1).strip()
                if len(message) > 10 and '${' not in message:
                    results['operation'].add(message)
            
            # 3. ERROR_MESSAGES = { KEY: 'message', ... }
            error_msg_pattern = r"ERROR_MESSAGES\s*=\s*\{([^}]+)\}"
            error_msg_match = re.search(error_msg_pattern, content, re.DOTALL)
            if error_msg_match:
                msg_block = error_msg_match.group(1)
                for match in re.finditer(r"([A-Z_]+):\s*['\"]([^'\"]+)['\"]", msg_block):
                    message = match.group(2).strip()
                    if message:
                        results['constants'].add(message)
            
            # 4. errorMapping = { 403: 'message', ... }
            error_map_pattern = r"errorMapping\s*:?\s*I?\w*\s*=\s*\{([^}]+)\}"
            error_map_match = re.search(error_map_pattern, content, re.DOTALL)
            if error_map_match:
                map_block = error_map_match.group(1)
                for match in re.finditer(r"(\d+):\s*['\"]([^'\"]+)['\"]", map_block):
                    code = int(match.group(1))
                    message = match.group(2).strip()
                    if message:
                        results['http'][code] = message
        
        except Exception:
            pass
    
    return results

def scan_all_services():
    """
    Scanne TOUS les services et compile TOUTES les erreurs
    """
    services = load_services()
    all_errors = []
    
    print("\n" + "="*80)
    print("EXTRACTION COMPLETE DES ERROR MESSAGES N8N -> LYXAL")
    print("="*80 + "\n")
    
    services_with_errors = 0
    
    for service in services:
        service_name = service['Service']
        service_slug = slugify(service_name)
        node_file = service.get('NodeFile', '')
        
        if not node_file:
            continue
        
        service_dir = Path(node_file).parent
        if not service_dir.exists():
            continue
        
        # Scanner tout le dossier
        results = scan_service_directory(service_dir)
        
        total_errors = 0
        
        # Ajouter les erreurs de validation
        for message in results['validation']:
            all_errors.append({
                'service_slug': service_slug,
                'error_type': 'validation',
                'message': message,
                'source_file': 'Description.ts files'
            })
            total_errors += 1
        
        # Ajouter les erreurs d'opération
        for message in results['operation']:
            all_errors.append({
                'service_slug': service_slug,
                'error_type': 'operation',
                'message': message,
                'source_file': '.node.ts files'
            })
            total_errors += 1
        
        # Ajouter les erreurs des constants
        for message in results['constants']:
            all_errors.append({
                'service_slug': service_slug,
                'error_type': 'validation',
                'message': message,
                'source_file': 'constants.ts'
            })
            total_errors += 1
        
        # Ajouter les error mappings HTTP
        for code, message in results['http'].items():
            all_errors.append({
                'service_slug': service_slug,
                'error_type': 'http',
                'http_code': code,
                'message': message,
                'source_file': 'GenericFunctions.ts or transport/index.ts'
            })
            total_errors += 1
        
        if total_errors > 0:
            print(f"OK {service_name:30} -> {total_errors:3} error messages")
            services_with_errors += 1
    
    print("\n" + "="*80)
    print(f"EXTRACTION TERMINEE")
    print(f"Services analyses : {len(services)}")
    print(f"Services avec erreurs : {services_with_errors}")
    print(f"Total error messages extraits : {len(all_errors)}")
    print("="*80 + "\n")
    
    return all_errors

def save_errors(errors: List[Dict]):
    """Sauvegarde les erreurs en JSON"""
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(errors, f, indent=2, ensure_ascii=False)
    
    print(f"Fichier de sortie : {OUTPUT_PATH}\n")

def main():
    """Fonction principale"""
    errors = scan_all_services()
    save_errors(errors)

if __name__ == "__main__":
    main()

