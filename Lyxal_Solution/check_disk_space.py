#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import shutil
from pathlib import Path

def check_disk_space():
    # Vérifier l'espace disque
    disk_usage = shutil.disk_usage(".")
    
    free_gb = disk_usage.free / (1024**3)
    total_gb = disk_usage.total / (1024**3)
    used_gb = disk_usage.used / (1024**3)
    
    print("=" * 80)
    print("VÉRIFICATION ESPACE DISQUE")
    print("=" * 80)
    print()
    print(f"💾 Disque total: {total_gb:.1f} GB")
    print(f"📊 Utilisé: {used_gb:.1f} GB ({(used_gb/total_gb)*100:.1f}%)")
    print(f"✅ Disponible: {free_gb:.1f} GB")
    print()
    print("=" * 80)
    print("RECOMMANDATIONS")
    print("=" * 80)
    print()
    
    if free_gb >= 200:
        print("✅ Espace suffisant pour OSM Planet complet (75 GB + extraction)")
        print("   → Vous pouvez télécharger planet-latest.osm.pbf")
    elif free_gb >= 80:
        print("⚠️  Espace limité pour Planet complet")
        print("✅ Espace suffisant pour extraits régionaux (28 GB + extraction)")
        print("   → Recommandation: Télécharger par régions")
    elif free_gb >= 15:
        print("⚠️  Espace limité")
        print("✅ Espace suffisant pour test France (3.5 GB + extraction)")
        print("   → Recommandation: Commencer avec la France")
    else:
        print("❌ Espace disque insuffisant")
        print(f"   → Libérez au moins {15 - free_gb:.1f} GB")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    check_disk_space()

