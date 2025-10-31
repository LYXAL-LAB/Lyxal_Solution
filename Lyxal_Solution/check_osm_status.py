#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

def check_status():
    print("=" * 80)
    print("ÉTAT DES DONNÉES OSM")
    print("=" * 80)
    print()
    
    osm_dir = Path("osm_data")
    
    print("📂 Dossier: osm_data/")
    print()
    
    # Fichier téléchargé
    france_pbf = osm_dir / "france-latest.osm.pbf"
    if france_pbf.exists():
        size_gb = france_pbf.stat().st_size / (1024**3)
        print(f"✅ TÉLÉCHARGÉ: france-latest.osm.pbf")
        print(f"   Taille: {size_gb:.2f} GB")
        print(f"   Chemin: {france_pbf.absolute()}")
        print(f"   Type: Fichier OSM PBF (BRUT - non extrait)")
        print()
    else:
        print("❌ Fichier france-latest.osm.pbf non trouvé")
        print()
    
    # Fichiers extraits
    print("📦 EXTRACTIONS:")
    print()
    
    boundaries_pbf = osm_dir / "france-boundaries.osm.pbf"
    if boundaries_pbf.exists():
        print(f"   ✅ france-boundaries.osm.pbf (filtré)")
    else:
        print(f"   ⚪ france-boundaries.osm.pbf (PAS ENCORE EXTRAIT)")
    
    roads_pbf = osm_dir / "france-roads.osm.pbf"
    if roads_pbf.exists():
        print(f"   ✅ france-roads.osm.pbf (filtré)")
    else:
        print(f"   ⚪ france-roads.osm.pbf (PAS ENCORE EXTRAIT)")
    
    poi_pbf = osm_dir / "france-poi.osm.pbf"
    if poi_pbf.exists():
        print(f"   ✅ france-poi.osm.pbf (filtré)")
    else:
        print(f"   ⚪ france-poi.osm.pbf (PAS ENCORE EXTRAIT)")
    
    print()
    
    # Fichiers convertis
    print("🗺️  CONVERSIONS GeoJSON:")
    print()
    
    boundaries_json = osm_dir / "france-boundaries.geojson"
    if boundaries_json.exists():
        size_mb = boundaries_json.stat().st_size / (1024**2)
        print(f"   ✅ france-boundaries.geojson ({size_mb:.1f} MB)")
    else:
        print(f"   ⚪ france-boundaries.geojson (PAS ENCORE CONVERTI)")
    
    print()
    print("=" * 80)
    print("RÉSUMÉ")
    print("=" * 80)
    print()
    
    if france_pbf.exists():
        print("✅ Vous avez le fichier OSM France BRUT (4.54 GB)")
        print()
        print("⚠️  IMPORTANT: Ce fichier contient TOUTES les données")
        print("   mais n'est PAS encore exploitable directement.")
        print()
        print("🎯 Il faut maintenant EXTRAIRE les données selon vos besoins:")
        print()
        print("   Option 1: Extraire les boundaries uniquement")
        print("   Option 2: Extraire boundaries + routes")
        print("   Option 3: Extraire boundaries + routes + POI")
        print("   Option 4: Importer tout dans PostgreSQL")
        print()
        print("💡 Une fois que vous m'aurez dit votre nouvelle conception,")
        print("   je pourrai extraire exactement ce dont vous avez besoin.")
    else:
        print("❌ Fichier OSM pas encore téléchargé")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    check_status()

