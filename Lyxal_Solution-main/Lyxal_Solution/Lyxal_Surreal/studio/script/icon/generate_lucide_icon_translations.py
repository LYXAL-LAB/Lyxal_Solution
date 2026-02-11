#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour générer les traductions des icônes Lucide extraites
"""

import json
from pathlib import Path
from typing import Dict, List

# Chemins
LUCIDE_ICONS_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\icons")
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\reference\icon\icon")

def slugify(text: str) -> str:
    """Convertir en slug"""
    return text.lower().replace(' ', '_').replace('-', '_').replace('&', 'and')

def capitalize_words(text: str) -> str:
    """Capitaliser chaque mot"""
    return ' '.join(word.capitalize() for word in text.replace('-', ' ').replace('_', ' ').split())

def translate_icon_name(icon_name: str, language: str) -> Dict[str, str]:
    """
    Traduire le nom et le label d'une icône
    Pour l'instant, on utilise le nom capitalisé comme base
    Les traductions spécifiques peuvent être ajoutées au besoin
    """
    # Nom formaté
    display_name = capitalize_words(icon_name)
    
    # Pour le nom (description longue), on garde le formatage
    name = display_name
    
    # Pour le label (court), on garde aussi le même
    label = display_name
    
    return {
        'name': name,
        'label': label
    }

def extract_icons() -> List[Dict]:
    """Extraire toutes les icônes"""
    icons = []
    
    print(f"🔍 Scan de {LUCIDE_ICONS_DIR}...")
    icon_files = sorted(LUCIDE_ICONS_DIR.glob('*.json'))
    print(f"   Trouvé {len(icon_files)} fichiers d'icônes")
    
    for icon_file in icon_files:
        icon_name = icon_file.stem
        
        try:
            with open(icon_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            icon_info = {
                'name': icon_name,
                'value': slugify(icon_name),
                'tags': data.get('tags', [])
            }
            
            icons.append(icon_info)
            
        except Exception as e:
            print(f"⚠️  Erreur lecture {icon_name}: {e}")
    
    return icons

def generate_translations(icons: List[Dict]) -> str:
    """Générer le fichier de traductions"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: i18n_translation for icon (Lucide - complet)")
    output.append("-- =============================================================================")
    output.append("-- Traductions pour toutes les icônes Lucide")
    output.append("-- Langues: FR, EN, IT, DE, ES")
    output.append("-- Ordre de déploiement : Après icon_i18n_key_seeds_lucide_all.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    total = len(icons)
    
    for idx, icon in enumerate(icons, 1):
        if idx % 100 == 0:
            print(f"   Progression: {idx}/{total} icônes...")
        
        value = icon['value']
        name = icon['name']
        
        output.append(f"-- {idx}. {name}")
        
        for lang in ['fr', 'en', 'it', 'de', 'es']:
            trans = translate_icon_name(name, lang)
            
            # Traduction du name
            output.append(f"RELATE i18n_key:icon_{value}_name->translation->language:{lang}")
            output.append(f"  SET text = '{trans['name']}';")
            output.append("")
            
            # Traduction du label
            output.append(f"RELATE i18n_key:icon_{value}_label->translation->language:{lang}")
            output.append(f"  SET text = '{trans['label']}';")
            output.append("")
    
    return "\n".join(output)

def main():
    """Fonction principale"""
    print("🌐 Génération des traductions pour les icônes Lucide...")
    
    # Extraire les icônes
    icons = extract_icons()
    print(f"✅ {len(icons)} icônes trouvées")
    
    # Générer les traductions
    print("\n📝 Génération des traductions...")
    print(f"   Cela va créer {len(icons) * 2 * 5} traductions (icônes × 2 × 5 langues)")
    
    translations = generate_translations(icons)
    
    # Écrire le fichier
    output_file = OUTPUT_DIR / "icon_i18n_translation_seeds_lucide_all.surql"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(translations)
    
    print(f"\n✅ Fichier créé : {output_file.name}")
    print(f"\n📊 Statistiques :")
    print(f"   - {len(icons)} icônes")
    print(f"   - {len(icons) * 2} clés i18n (name + label)")
    print(f"   - 5 langues (FR, EN, IT, DE, ES)")
    print(f"   - {len(icons) * 2 * 5} traductions totales")
    
    print(f"\n✅ Génération terminée !")

if __name__ == '__main__':
    main()

