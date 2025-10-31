#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extraction des boundaries administratives depuis OSM France.
Utilise osmium pour filtrer admin_level 8-10 (villes/communes).
"""

import subprocess
from pathlib import Path
import sys

def extract_boundaries():
    """Extrait les boundaries avec osmium-tool."""
    
    print("=" * 80)
    print("EXTRACTION DES BOUNDARIES - FRANCE")
    print("=" * 80)
    print()
    
    input_file = Path("osm_data/france-latest.osm.pbf")
    output_file = Path("osm_data/france-boundaries.osm.pbf")
    
    if not input_file.exists():
        print(f"❌ Fichier source introuvable: {input_file}")
        print("   → Lancez d'abord: python download_osm_france.py")
        return False
    
    print(f"📂 Source: {input_file} ({input_file.stat().st_size / (1024**3):.2f} GB)")
    print(f"📂 Destination: {output_file}")
    print()
    
    # Vérifier si osmium est installé
    try:
        result = subprocess.run(['osmium', '--version'], capture_output=True, text=True)
        print(f"✅ osmium version: {result.stdout.strip()}")
    except FileNotFoundError:
        print("❌ osmium-tool n'est pas installé")
        print()
        print("Installation:")
        print("   pip install osmium")
        print("   # ou")
        print("   conda install -c conda-forge osmium-tool")
        return False
    
    print()
    print("⏳ Extraction en cours (peut prendre 5-10 minutes)...")
    print()
    
    # Commande osmium pour extraire boundaries admin
    cmd = [
        'osmium', 'tags-filter',
        str(input_file),
        'w/boundary=administrative',
        'r/boundary=administrative',
        '-o', str(output_file),
        '--overwrite'
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        
        print("✅ Extraction terminée!")
        print(f"💾 Fichier créé: {output_file}")
        print(f"📊 Taille: {output_file.stat().st_size / (1024**2):.1f} MB")
        print()
        
        # Créer marqueur
        Path("osm_data/france_boundaries_extracted.flag").write_text("OK")
        
        print("🎯 Prochaine étape:")
        print("   python convert_to_geojson.py")
        print()
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Erreur lors de l'extraction: {e}")
        print(f"   stderr: {e.stderr}")
        return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


if __name__ == "__main__":
    success = extract_boundaries()
    sys.exit(0 if success else 1)

