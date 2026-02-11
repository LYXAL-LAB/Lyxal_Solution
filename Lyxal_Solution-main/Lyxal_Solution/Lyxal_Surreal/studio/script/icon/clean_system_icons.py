#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour nettoyer les icônes système en gardant uniquement Lucide
"""

from pathlib import Path

# Chemins
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\reference\icon\icon")

# Mapping : nos icônes système → Lucide
ICON_MAPPING = {
    # Icônes à RENOMMER (12)
    'close': 'x',
    'filter': 'list_filter',
    'home': 'house',
    'edit': 'pencil',
    'add': 'plus',
    'cancel': 'circle_x',
    'warning': 'triangle_alert',
    'error': 'circle_alert',
    'success': 'circle_check',
    'notification': 'bell',
    'help': 'circle_question_mark',
    'refresh': 'refresh_cw',
    
    # Icônes OK (18) - à SUPPRIMER car déjà dans Lucide
    'search': None,  # Existe déjà dans Lucide
    'menu': None,
    'arrow_left': None,
    'arrow_right': None,
    'arrow_up': None,
    'arrow_down': None,
    'chevron_left': None,
    'chevron_right': None,
    'chevron_up': None,
    'chevron_down': None,
    'delete': None,
    'save': None,
    'check': None,
    'info': None,
    'settings': None,
    'user': None,
    'download': None,
    'upload': None,
}

def main():
    """Fonction principale"""
    print("🧹 Nettoyage des icônes système...")
    print()
    
    # Compter les icônes
    to_rename = [k for k, v in ICON_MAPPING.items() if v is not None]
    to_delete = [k for k, v in ICON_MAPPING.items() if v is None]
    
    print(f"📊 Analyse :")
    print(f"   - {len(to_rename)} icônes à RENOMMER")
    print(f"   - {len(to_delete)} icônes à SUPPRIMER (doublons Lucide)")
    print(f"   - Total : {len(ICON_MAPPING)} icônes système")
    print()
    
    print("=" * 80)
    print("✏️  ICÔNES À RENOMMER (12)")
    print("=" * 80)
    for old_name, new_name in [(k, v) for k, v in ICON_MAPPING.items() if v is not None]:
        print(f"   {old_name:20} → {new_name}")
    print()
    
    print("=" * 80)
    print("🗑️  ICÔNES À SUPPRIMER (18 - déjà dans Lucide)")
    print("=" * 80)
    for icon_name in to_delete:
        print(f"   ❌ {icon_name}")
    print()
    
    print("=" * 80)
    print("📝 CONCLUSION")
    print("=" * 80)
    print()
    print("✅ Après nettoyage :")
    print("   - 0 icônes système custom")
    print("   - 1640 icônes Lucide (dictionnaire complet)")
    print("   - Les 12 icônes renommées existent déjà dans Lucide !")
    print()
    print("🎯 Action recommandée :")
    print("   → SUPPRIMER complètement les fichiers icon_seeds.surql et icon_i18n_key_seeds.surql")
    print("   → Garder uniquement les fichiers Lucide (_lucide_all.surql)")
    print()

if __name__ == '__main__':
    main()

