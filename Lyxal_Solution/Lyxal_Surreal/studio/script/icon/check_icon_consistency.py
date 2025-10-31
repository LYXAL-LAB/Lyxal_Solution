#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour vérifier la cohérence entre les icônes système et Lucide
"""

import json
from pathlib import Path
from typing import List, Dict, Set

# Chemins
LUCIDE_ICONS_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\icons")

# Liste des 30 icônes système (value, slug)
SYSTEM_ICONS = [
    ('close', 'close'),
    ('search', 'search'),
    ('filter', 'filter'),
    ('menu', 'menu'),
    ('home', 'home'),
    ('arrow_left', 'arrow-left'),
    ('arrow_right', 'arrow-right'),
    ('arrow_up', 'arrow-up'),
    ('arrow_down', 'arrow-down'),
    ('chevron_left', 'chevron-left'),
    ('chevron_right', 'chevron-right'),
    ('chevron_up', 'chevron-up'),
    ('chevron_down', 'chevron-down'),
    ('edit', 'edit'),
    ('delete', 'delete'),
    ('add', 'add'),
    ('save', 'save'),
    ('cancel', 'cancel'),
    ('check', 'check'),
    ('info', 'info'),
    ('warning', 'warning'),
    ('error', 'error'),
    ('success', 'success'),
    ('settings', 'settings'),
    ('user', 'user'),
    ('notification', 'notification'),
    ('help', 'help'),
    ('download', 'download'),
    ('upload', 'upload'),
    ('refresh', 'refresh')
]

def get_lucide_icons() -> Set[str]:
    """Récupérer tous les slugs Lucide"""
    lucide_icons = set()
    
    for icon_file in LUCIDE_ICONS_DIR.glob('*.json'):
        lucide_icons.add(icon_file.stem)
    
    return lucide_icons

def check_consistency():
    """Vérifier la cohérence"""
    print("🔍 Vérification de la cohérence entre icônes système et Lucide...")
    print()
    
    lucide_icons = get_lucide_icons()
    print(f"✅ {len(lucide_icons)} icônes Lucide trouvées")
    print()
    
    # Mapping des slugs système vers Lucide
    matches = []
    no_matches = []
    suggestions = {}
    
    for value, slug in SYSTEM_ICONS:
        # Chercher si le slug existe dans Lucide
        if slug in lucide_icons:
            matches.append((value, slug, '✅ Match exact'))
        else:
            # Chercher des correspondances proches
            close_matches = [icon for icon in lucide_icons if slug.replace('-', '_') in icon or icon in slug]
            
            no_matches.append((value, slug))
            if close_matches:
                suggestions[slug] = close_matches[:5]  # Max 5 suggestions
    
    # Afficher les résultats
    print("=" * 80)
    print("RÉSULTATS DE LA VÉRIFICATION")
    print("=" * 80)
    print()
    
    print(f"✅ {len(matches)}/{len(SYSTEM_ICONS)} icônes système correspondent à Lucide")
    print(f"⚠️  {len(no_matches)}/{len(SYSTEM_ICONS)} icônes système n'ont PAS de correspondance exacte")
    print()
    
    if matches:
        print("=" * 80)
        print("✅ CORRESPONDANCES EXACTES")
        print("=" * 80)
        for value, slug, status in matches:
            print(f"  • {value:20} → {slug:20} {status}")
        print()
    
    if no_matches:
        print("=" * 80)
        print("⚠️  ICÔNES SANS CORRESPONDANCE EXACTE")
        print("=" * 80)
        for value, slug in no_matches:
            print(f"  • {value:20} → {slug:20}")
            if slug in suggestions:
                print(f"    Suggestions Lucide: {', '.join(suggestions[slug])}")
        print()
    
    # Recommandations
    print("=" * 80)
    print("📝 RECOMMANDATIONS")
    print("=" * 80)
    print()
    
    if len(matches) == len(SYSTEM_ICONS):
        print("✅ Parfait ! Toutes les icônes système correspondent à Lucide.")
        print("   → Aucune modification nécessaire")
    else:
        print("⚠️  Certaines icônes système n'ont pas de correspondance exacte dans Lucide.")
        print()
        print("Options possibles :")
        print("  1. Renommer les icônes système pour correspondre à Lucide")
        print("  2. Créer des variantes custom pour ces icônes")
        print("  3. Utiliser les suggestions de correspondance proche")
    
    print()

if __name__ == '__main__':
    check_consistency()

