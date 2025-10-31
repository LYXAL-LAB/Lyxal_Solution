#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour extraire les icônes depuis Lucide et générer les seeds enrichis
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

def extract_icons() -> List[Dict]:
    """Extraire toutes les icônes depuis les fichiers JSON"""
    icons = []
    
    print(f"🔍 Scan de {LUCIDE_ICONS_DIR}...")
    icon_files = sorted(LUCIDE_ICONS_DIR.glob('*.json'))
    print(f"   Trouvé {len(icon_files)} fichiers d'icônes")
    
    for icon_file in icon_files:
        icon_name = icon_file.stem  # a-arrow-down, accessibility, etc.
        
        try:
            with open(icon_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Récupérer les infos
            tags = data.get('tags', [])
            categories = data.get('categories', [])
            
            # Prendre la première catégorie comme catégorie principale
            primary_category = categories[0] if categories else 'other'
            
            icon_info = {
                'name': icon_name,
                'slug': icon_name,
                'value': slugify(icon_name),
                'tags': tags,
                'categories': [slugify(cat) for cat in categories],
                'primary_category': slugify(primary_category)
            }
            
            icons.append(icon_info)
            
        except Exception as e:
            print(f"⚠️  Erreur lecture {icon_name}: {e}")
    
    return icons

def generate_i18n_keys(icons: List[Dict], limit: int = None) -> str:
    """Générer le fichier des clés i18n (limité pour éviter un fichier trop gros)"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: i18n_key for icon (Lucide - sélection)")
    output.append("-- =============================================================================")
    output.append("-- Clés i18n pour une sélection d'icônes Lucide")
    output.append("-- Ordre de déploiement : Avant icon_seeds_lucide.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    icons_to_process = icons[:limit] if limit else icons
    
    for icon in icons_to_process:
        value = icon['value']
        output.append(f"-- {icon['name']}")
        output.append(f"CREATE i18n_key:icon_{value}_name CONTENT {{")
        output.append(f"  context: 'icon',")
        output.append(f"  description: 'Nom de l\\'icône {icon['name']}'")
        output.append("};")
        output.append("")
        output.append(f"CREATE i18n_key:icon_{value}_label CONTENT {{")
        output.append(f"  context: 'icon',")
        output.append(f"  description: 'Label de l\\'icône {icon['name']}'")
        output.append("};")
        output.append("")
    
    return "\n".join(output)

def generate_seeds(icons: List[Dict], limit: int = None) -> str:
    """Générer le fichier des seeds (limité pour commencer)"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: icon (Lucide - sélection)")
    output.append("-- =============================================================================")
    output.append("-- Dictionnaire d'icônes enrichi depuis Lucide")
    output.append("-- Ordre de déploiement : Après icon_seeds_lucide_i18n_key_seeds.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    icons_to_process = icons[:limit] if limit else icons
    
    for idx, icon in enumerate(icons_to_process, 1):
        value = icon['value']
        name = icon['name']
        category = icon['primary_category']
        tags = icon['tags']
        
        # Construire la liste de keywords (name + tags)
        keywords = [name] + tags
        
        output.append(f"-- {idx}. {name}")
        output.append(f"CREATE icon:{value} CONTENT {{")
        output.append("  identity: {")
        output.append(f"    value: '{value}',")
        output.append(f"    slug: '{icon['slug']}'")
        output.append("  },")
        output.append("  presentation: {")
        output.append(f"    name_i18n: i18n_key:icon_{value}_name,")
        output.append(f"    label_i18n: i18n_key:icon_{value}_label,")
        output.append(f"    keywords: {json.dumps(keywords)}")
        output.append("  },")
        output.append("  context: {")
        output.append(f"    category: icon_category:{category},")
        output.append("    usage_hints: [],")
        output.append("    semantic_meaning: NONE")
        output.append("  },")
        output.append("  status: {")
        output.append("    is_active: true,")
        output.append("    is_system_icon: true,")
        output.append("    source: 'system'")
        output.append("  },")
        output.append("  timestamp: {}")
        output.append("};")
        output.append("")
    
    return "\n".join(output)

def generate_summary(icons: List[Dict]) -> str:
    """Générer un fichier de résumé avec des statistiques"""
    output = []
    output.append("# Extraction des icônes Lucide")
    output.append("")
    output.append(f"## Statistiques")
    output.append("")
    output.append(f"- **Total icônes** : {len(icons)}")
    output.append("")
    
    # Compter par catégorie
    by_category = {}
    for icon in icons:
        cat = icon['primary_category']
        by_category[cat] = by_category.get(cat, 0) + 1
    
    output.append(f"## Répartition par catégorie ({len(by_category)} catégories)")
    output.append("")
    for cat in sorted(by_category.keys()):
        count = by_category[cat]
        output.append(f"- **{cat}** : {count} icônes")
    
    output.append("")
    output.append("## Exemples d'icônes")
    output.append("")
    for i, icon in enumerate(icons[:20], 1):
        output.append(f"{i}. `{icon['name']}` - {icon['primary_category']} - tags: {', '.join(icon['tags'][:3])}")
    
    return "\n".join(output)

def main():
    """Fonction principale"""
    print("🔍 Extraction des icônes depuis Lucide...")
    icons = extract_icons()
    print(f"✅ {len(icons)} icônes extraites")
    
    # Générer TOUTES les icônes
    limit = None  # None = toutes les icônes
    print(f"\n✅ Génération de TOUTES les {len(icons)} icônes...")
    
    # Générer les clés i18n
    print("\n📝 Génération des clés i18n...")
    i18n_keys = generate_i18n_keys(icons, limit=limit)
    suffix = "all" if limit is None else str(limit)
    i18n_keys_file = OUTPUT_DIR / f"icon_i18n_key_seeds_lucide_{suffix}.surql"
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write(i18n_keys)
    print(f"✅ Fichier créé : {i18n_keys_file.name}")
    
    # Générer les seeds
    print("\n📝 Génération des seeds...")
    seeds = generate_seeds(icons, limit=limit)
    seeds_file = OUTPUT_DIR / f"icon_seeds_lucide_{suffix}.surql"
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write(seeds)
    print(f"✅ Fichier créé : {seeds_file.name}")
    
    # Générer le résumé
    print("\n📝 Génération du résumé...")
    summary = generate_summary(icons)
    summary_file = OUTPUT_DIR / "LUCIDE_ICONS_SUMMARY.md"
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write(summary)
    print(f"✅ Fichier créé : {summary_file.name}")
    
    print(f"\n✅ Extraction terminée !")
    print(f"\n📊 Statistiques :")
    print(f"   - {len(icons)} icônes totales disponibles")
    generated_count = len(icons) if limit is None else limit
    print(f"   - {generated_count} icônes générées dans les seeds")
    print(f"   - {generated_count * 2} clés i18n (name + label)")
    
    # Compter par catégorie
    by_category = {}
    icons_to_count = icons if limit is None else icons[:limit]
    for icon in icons_to_count:
        cat = icon['primary_category']
        by_category[cat] = by_category.get(cat, 0) + 1
    
    print(f"   - {len(by_category)} catégories utilisées")

if __name__ == '__main__':
    main()

