#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Téléchargement d'OSM Planet avec suivi de progression.
"""

import requests
import os
from pathlib import Path
from datetime import datetime
import time

def download_osm_planet():
    """Télécharge OSM Planet avec barre de progression."""
    
    # Créer le dossier de destination
    osm_dir = Path("osm_data")
    osm_dir.mkdir(exist_ok=True)
    
    # URL OSM Planet
    url = "https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
    output_file = osm_dir / "planet-latest.osm.pbf"
    
    print("=" * 80)
    print("TÉLÉCHARGEMENT OSM PLANET")
    print("=" * 80)
    print()
    print(f"📥 Source: {url}")
    print(f"💾 Destination: {output_file}")
    print(f"📊 Taille attendue: ~75 GB")
    print()
    print("⏳ Démarrage du téléchargement...")
    print()
    
    # Vérifier si le fichier existe déjà
    if output_file.exists():
        existing_size = output_file.stat().st_size / (1024**3)
        print(f"⚠️  Fichier existant détecté ({existing_size:.2f} GB)")
        response = input("Voulez-vous reprendre le téléchargement ? (o/n): ")
        if response.lower() != 'o':
            print("❌ Téléchargement annulé")
            return
        resume_byte = output_file.stat().st_size
    else:
        resume_byte = 0
    
    # Headers pour reprendre le téléchargement
    headers = {}
    if resume_byte > 0:
        headers['Range'] = f'bytes={resume_byte}-'
    
    try:
        # Démarrer le téléchargement
        start_time = time.time()
        
        response = requests.get(url, headers=headers, stream=True, timeout=30)
        total_size = int(response.headers.get('content-length', 0)) + resume_byte
        
        mode = 'ab' if resume_byte > 0 else 'wb'
        
        with open(output_file, mode) as f:
            downloaded = resume_byte
            chunk_size = 8192 * 1024  # 8 MB chunks
            last_print = time.time()
            
            for chunk in response.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    
                    # Afficher la progression toutes les 2 secondes
                    current_time = time.time()
                    if current_time - last_print >= 2:
                        percent = (downloaded / total_size) * 100
                        downloaded_gb = downloaded / (1024**3)
                        total_gb = total_size / (1024**3)
                        elapsed = current_time - start_time
                        speed_mbps = (downloaded - resume_byte) / elapsed / (1024**2)
                        eta_seconds = (total_size - downloaded) / (speed_mbps * 1024**2) if speed_mbps > 0 else 0
                        eta_hours = eta_seconds / 3600
                        
                        print(f"📊 {percent:.1f}% | {downloaded_gb:.2f}/{total_gb:.2f} GB | "
                              f"Vitesse: {speed_mbps:.2f} MB/s | ETA: {eta_hours:.1f}h", 
                              end='\r')
                        last_print = current_time
        
        print()
        print()
        print("=" * 80)
        print("✅ TÉLÉCHARGEMENT TERMINÉ")
        print("=" * 80)
        print(f"📁 Fichier: {output_file}")
        print(f"💾 Taille: {output_file.stat().st_size / (1024**3):.2f} GB")
        print(f"⏱️  Durée: {(time.time() - start_time) / 3600:.1f} heures")
        print()
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Téléchargement interrompu par l'utilisateur")
        print(f"📊 {downloaded / (1024**3):.2f} GB téléchargés")
        print("💡 Vous pouvez reprendre le téléchargement en relançant ce script")
        
    except Exception as e:
        print(f"\n\n❌ Erreur: {e}")
        print("💡 Vous pouvez reprendre le téléchargement en relançant ce script")


if __name__ == "__main__":
    download_osm_planet()

