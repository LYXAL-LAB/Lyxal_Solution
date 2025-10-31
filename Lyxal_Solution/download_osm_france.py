#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Téléchargement OSM France depuis Geofabrik.
"""

import requests
from pathlib import Path
import time

def download_file(url, output_path):
    """Télécharge un fichier avec progression."""
    
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Vérifier si existe déjà
    resume_byte = 0
    if output_path.exists():
        resume_byte = output_path.stat().st_size
        print(f"⚠️  Fichier existant: {resume_byte / (1024**3):.2f} GB")
        print(f"♻️  Reprise du téléchargement...\n")
    
    headers = {}
    if resume_byte > 0:
        headers['Range'] = f'bytes={resume_byte}-'
    
    print(f"📥 Téléchargement depuis: {url}")
    print(f"💾 Destination: {output_path}")
    print()
    
    start_time = time.time()
    
    try:
        response = requests.get(url, headers=headers, stream=True, timeout=60)
        
        if response.status_code not in [200, 206]:
            print(f"❌ Erreur HTTP: {response.status_code}")
            return False
        
        total_size = int(response.headers.get('content-length', 0)) + resume_byte
        
        mode = 'ab' if resume_byte > 0 else 'wb'
        
        with open(output_path, mode) as f:
            downloaded = resume_byte
            chunk_size = 8192 * 1024  # 8 MB
            last_print = time.time()
            
            for chunk in response.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    
                    current_time = time.time()
                    if current_time - last_print >= 1:
                        percent = (downloaded / total_size) * 100 if total_size > 0 else 0
                        downloaded_gb = downloaded / (1024**3)
                        total_gb = total_size / (1024**3)
                        elapsed = current_time - start_time
                        speed_mbps = (downloaded - resume_byte) / elapsed / (1024**2) if elapsed > 0 else 0
                        eta_seconds = (total_size - downloaded) / (speed_mbps * 1024**2) if speed_mbps > 0 else 0
                        eta_minutes = eta_seconds / 60
                        
                        print(f"📊 {percent:.1f}% | {downloaded_gb:.2f}/{total_gb:.2f} GB | "
                              f"{speed_mbps:.2f} MB/s | ETA: {eta_minutes:.0f}min", 
                              end='\r', flush=True)
                        last_print = current_time
        
        print()
        print()
        elapsed_total = time.time() - start_time
        print(f"✅ Téléchargement terminé en {elapsed_total/60:.1f} minutes")
        print(f"💾 Taille finale: {output_path.stat().st_size / (1024**3):.2f} GB")
        return True
        
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        return False


def main():
    print("=" * 80)
    print("TÉLÉCHARGEMENT OSM FRANCE")
    print("=" * 80)
    print()
    
    # URL Geofabrik France
    url = "https://download.geofabrik.de/europe/france-latest.osm.pbf"
    output = "osm_data/france-latest.osm.pbf"
    
    print("📋 Informations:")
    print("   - Source: Geofabrik")
    print("   - Région: France")
    print("   - Taille: ~3.5 GB")
    print("   - Format: OSM PBF (Protocol Buffer Format)")
    print("   - Couverture: ~10,000 villes françaises")
    print()
    print("⏳ Démarrage...")
    print()
    
    success = download_file(url, output)
    
    if success:
        print()
        print("=" * 80)
        print("✅ TÉLÉCHARGEMENT FRANCE RÉUSSI")
        print("=" * 80)
        print()
        print("📁 Fichier téléchargé: osm_data/france-latest.osm.pbf")
        print()
        print("🎯 Prochaines étapes:")
        print("   1. Extraire les boundaries: python extract_boundaries_france.py")
        print("   2. Convertir en GeoJSON: python convert_to_geojson.py")
        print("   3. Matcher avec vos villes: python match_cities.py")
        print()
        
        # Créer un marqueur de succès
        Path("osm_data/france_download_complete.flag").write_text(
            f"Téléchargement terminé: {time.strftime('%Y-%m-%d %H:%M:%S')}"
        )
    else:
        print()
        print("⚠️  Téléchargement incomplet ou échoué")
        print("💡 Vous pouvez relancer ce script pour reprendre")
    
    print("=" * 80)


if __name__ == "__main__":
    main()

