#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour extraire les catégories d'icônes depuis Lucide et générer les seeds
"""

import json
import os
from pathlib import Path
from typing import Dict, List

# Chemins
LUCIDE_CATEGORIES_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\categories")
LUCIDE_ICONS_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\icons")
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\reference\icon\icon_category")

# Display order commence après les 13 catégories existantes
START_DISPLAY_ORDER = 14

def slugify(text: str) -> str:
    """Convertir en slug"""
    return text.lower().replace(' ', '_').replace('-', '_')

def scan_icons_by_category() -> Dict[str, List[str]]:
    """Scanner tous les fichiers icons/ et regrouper par catégorie"""
    icons_by_category = {}
    
    print(f"🔍 Scan de {LUCIDE_ICONS_DIR}...")
    icon_files = list(LUCIDE_ICONS_DIR.glob('*.json'))
    print(f"   Trouvé {len(icon_files)} fichiers d'icônes")
    
    for icon_file in icon_files:
        icon_name = icon_file.stem  # a-arrow-down, accessibility, etc.
        
        try:
            with open(icon_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Récupérer les catégories de cette icône
            categories = data.get('categories', [])
            
            for category in categories:
                category_slug = slugify(category)
                if category_slug not in icons_by_category:
                    icons_by_category[category_slug] = []
                icons_by_category[category_slug].append(icon_name)
        except Exception as e:
            print(f"⚠️  Erreur lecture {icon_name}: {e}")
    
    # Trier les icônes dans chaque catégorie
    for category in icons_by_category:
        icons_by_category[category].sort()
    
    return icons_by_category

def extract_categories() -> List[Dict]:
    """Extraire toutes les catégories depuis les fichiers JSON"""
    categories = []
    
    # D'abord, scanner toutes les icônes pour avoir les exemples
    icons_by_category = scan_icons_by_category()
    
    for category_file in sorted(LUCIDE_CATEGORIES_DIR.glob('*.json')):
        category_slug = category_file.stem  # accessibility, account, etc.
        
        with open(category_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Récupérer les icônes de cette catégorie
        category_value = slugify(category_slug)
        icons = icons_by_category.get(category_value, [])
        
        # Extraire les infos
        category_info = {
            'slug': category_slug,
            'value': category_value,
            'name': data.get('title', category_slug.replace('-', ' ').title()),
            'description': data.get('description', ''),
            'icons': icons
        }
        
        categories.append(category_info)
    
    return categories

def map_to_theme_color_type(slug: str) -> str:
    """Mapper une catégorie vers un theme_color_type"""
    mapping = {
        'accessibility': 'info',
        'account': 'primary',
        'animals': 'success',
        'arrows': 'neutral',
        'brands': 'primary',
        'buildings': 'neutral',
        'charts': 'info',
        'communication': 'info',
        'connectivity': 'info',
        'cursors': 'neutral',
        'design': 'primary',
        'development': 'warning',
        'devices': 'neutral',
        'emoji': 'warning',
        'files': 'neutral',
        'finance': 'success',
        'food_beverage': 'success',
        'gaming': 'warning',
        'home': 'primary',
        'layout': 'neutral',
        'mail': 'info',
        'math': 'neutral',
        'medical': 'error',
        'multimedia': 'primary',
        'nature': 'success',
        'navigation': 'primary',
        'notifications': 'warning',
        'people': 'primary',
        'photography': 'info',
        'science': 'info',
        'seasons': 'success',
        'security': 'error',
        'shapes': 'neutral',
        'shopping': 'warning',
        'social': 'info',
        'sports': 'success',
        'sustainability': 'success',
        'text': 'neutral',
        'time': 'neutral',
        'tools': 'neutral',
        'transportation': 'neutral',
        'travel': 'success',
        'weather': 'info'
    }
    return mapping.get(slug, 'neutral')

def generate_i18n_keys(categories: List[Dict]) -> str:
    """Générer le fichier des clés i18n"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: i18n_key for icon_category (Lucide)")
    output.append("-- =============================================================================")
    output.append("-- Clés i18n pour les catégories d'icônes extraites de Lucide")
    output.append("-- Ordre de déploiement : Avant icon_category_seeds.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    for cat in categories:
        slug = cat['value']
        output.append(f"-- {cat['name']}")
        output.append(f"CREATE i18n_key:icon_category_{slug}_name CONTENT {{")
        output.append(f"  context: 'icon_category',")
        output.append(f"  description: 'Nom de la catégorie {cat['name']}'")
        output.append("};")
        output.append("")
        output.append(f"CREATE i18n_key:icon_category_{slug}_description CONTENT {{")
        output.append(f"  context: 'icon_category',")
        output.append(f"  description: 'Description de la catégorie {cat['name']}'")
        output.append("};")
        output.append("")
    
    return "\n".join(output)

def generate_seeds(categories: List[Dict]) -> str:
    """Générer le fichier des seeds"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: icon_category (Lucide)")
    output.append("-- =============================================================================")
    output.append("-- Catégories d'icônes extraites de Lucide (43 catégories)")
    output.append("-- Ordre de déploiement : Après icon_category_i18n_key_seeds.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    for idx, cat in enumerate(categories, START_DISPLAY_ORDER):
        slug = cat['value']
        color_type = map_to_theme_color_type(slug)
        
        output.append(f"-- {idx - START_DISPLAY_ORDER + 1}. {cat['name']}")
        output.append(f"CREATE icon_category:{slug} CONTENT {{")
        output.append("  identity: {")
        output.append(f"    value: '{slug}',")
        output.append(f"    slug: '{cat['slug']}'")
        output.append("  },")
        output.append("  presentation: {")
        output.append(f"    name_i18n: i18n_key:icon_category_{slug}_name,")
        output.append(f"    description_i18n: i18n_key:icon_category_{slug}_description")
        output.append("  },")
        output.append("  context: {")
        
        # Exemples d'icônes (prendre les 5 premiers)
        examples = cat['icons'][:5] if cat['icons'] else []
        # Générer des keywords basiques
        keywords = [slug, cat['name'].lower()]
        if '-' in cat['slug']:
            keywords.extend(cat['slug'].split('-'))
        
        output.append(f"    examples: {json.dumps(examples)},")
        output.append(f"    keywords: {json.dumps(keywords)}")
        output.append("  },")
        output.append("  metadata: {")
        output.append(f"    color_type: theme_color_type:{color_type},")
        output.append("    representative_icon: NONE,")
        output.append(f"    display_order: {idx}")
        output.append("  },")
        output.append("  status: {")
        output.append("    is_active: true,")
        output.append("    is_system: true,")
        output.append("    source: 'system'")
        output.append("  },")
        output.append("  timestamp: {}")
        output.append("};")
        output.append("")
    
    return "\n".join(output)

def main():
    """Fonction principale"""
    print("🔍 Extraction des catégories depuis Lucide...")
    categories = extract_categories()
    print(f"✅ {len(categories)} catégories extraites")
    
    # Générer les clés i18n
    print("\n📝 Génération des clés i18n...")
    i18n_keys = generate_i18n_keys(categories)
    i18n_keys_file = OUTPUT_DIR / "icon_category_i18n_key_seeds_lucide.surql"
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write(i18n_keys)
    print(f"✅ Fichier créé : {i18n_keys_file.name}")
    
    # Générer les seeds
    print("\n📝 Génération des seeds...")
    seeds = generate_seeds(categories)
    seeds_file = OUTPUT_DIR / "icon_category_seeds_lucide.surql"
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write(seeds)
    print(f"✅ Fichier créé : {seeds_file.name}")
    
    print("\n✅ Extraction terminée !")
    print(f"\n📊 Statistiques :")
    print(f"   - {len(categories)} catégories")
    print(f"   - {len(categories) * 2} clés i18n (name + description)")
    print(f"   - {sum(len(c['icons']) for c in categories)} icônes au total dans Lucide")

if __name__ == '__main__':
    main()

