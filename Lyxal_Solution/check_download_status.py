#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Vérifie l'état du téléchargement OSM.
"""

from pathlib import Path
import time

def check_status():
    print("=" * 80)
    print("ÉTAT DU TÉLÉCHARGEMENT OSM")
    print("=" * 80)
    print()
    
    osm_dir = Path("osm_data")
    france_file = osm_dir / "france-latest.osm.pbf"
    france_flag = osm_dir / "france_download_complete.flag"
    
    expected_size_gb = 3.5
    
    if france_flag.exists():
        print("✅ TÉLÉCHARGEMENT FRANCE: TERMINÉ")
        print(f"   Fichier: {france_file}")
        print(f"   Taille: {france_file.stat().st_size / (1024**3):.2f} GB")
        print(f"   Date: {france_flag.read_text().strip()}")
        print()
        print("🎯 Prêt pour l'extraction:")
        print("   python extract_boundaries_france.py")
    elif france_file.exists():
        current_size_gb = france_file.stat().st_size / (1024**3)
        percent = (current_size_gb / expected_size_gb) * 100
        print(f"⏳ TÉLÉCHARGEMENT FRANCE: EN COURS")
        print(f"   Progression: {percent:.1f}% ({current_size_gb:.2f}/{expected_size_gb:.1f} GB)")
        print(f"   Fichier: {france_file}")
        print()
        print("💡 Le téléchargement continue en arrière-plan")
        print("   Relancez ce script pour voir la progression")
    else:
        print("⚠️  TÉLÉCHARGEMENT PAS ENCORE DÉMARRÉ")
        print()
        print("Pour démarrer:")
        print("   python download_osm_france.py")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    check_status()

