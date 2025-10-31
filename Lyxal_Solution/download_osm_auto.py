#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Téléchargement automatique d'OSM Planet (non-interactif).
"""

import requests
import os
from pathlib import Path
import time
import sys

def download_osm_planet():
    """Télécharge OSM Planet avec barre de progression."""
    
    # Créer le dossier de destination
    osm_dir = Path("osm_data")
    osm_dir.mkdir(exist_ok=True)
    
    # URL OSM Planet
    url = "https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
    output_file = osm_dir / "planet-latest.osm.pbf"
    
    # Log file
    log_file = osm_dir / "download.log"
    
    def log(message):
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        log_msg = f"[{timestamp}] {message}"
        print(log_msg)
        with open(log_file, 'a', encoding='utf-8') as f:
            f.write(log_msg + "\n")
    
    log("=" * 80)
    log("TÉLÉCHARGEMENT OSM PLANET - MODE AUTOMATIQUE")
    log("=" * 80)
    log(f"📥 Source: {url}")
    log(f"💾 Destination: {output_file}")
    log(f"📊 Taille attendue: ~75 GB")
    log("")
    
    # Vérifier si le fichier existe déjà
    resume_byte = 0
    if output_file.exists():
        resume_byte = output_file.stat().st_size
        existing_size = resume_byte / (1024**3)
        log(f"⚠️  Fichier existant détecté ({existing_size:.2f} GB)")
        log(f"♻️  Reprise du téléchargement à partir de {existing_size:.2f} GB")
    
    # Headers pour reprendre le téléchargement
    headers = {}
    if resume_byte > 0:
        headers['Range'] = f'bytes={resume_byte}-'
    
    try:
        log("⏳ Démarrage du téléchargement...")
        
        # Démarrer le téléchargement
        start_time = time.time()
        
        response = requests.get(url, headers=headers, stream=True, timeout=60)
        
        if response.status_code not in [200, 206]:
            log(f"❌ Erreur HTTP: {response.status_code}")
            return False
        
        total_size = int(response.headers.get('content-length', 0)) + resume_byte
        
        mode = 'ab' if resume_byte > 0 else 'wb'
        
        with open(output_file, mode) as f:
            downloaded = resume_byte
            chunk_size = 8192 * 1024  # 8 MB chunks
            last_print = time.time()
            last_log = time.time()
            
            for chunk in response.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    
                    current_time = time.time()
                    
                    # Afficher console toutes les 2 secondes
                    if current_time - last_print >= 2:
                        percent = (downloaded / total_size) * 100
                        downloaded_gb = downloaded / (1024**3)
                        total_gb = total_size / (1024**3)
                        elapsed = current_time - start_time
                        speed_mbps = (downloaded - resume_byte) / elapsed / (1024**2)
                        eta_seconds = (total_size - downloaded) / (speed_mbps * 1024**2) if speed_mbps > 0 else 0
                        eta_hours = eta_seconds / 3600
                        
                        print(f"📊 {percent:.1f}% | {downloaded_gb:.2f}/{total_gb:.2f} GB | "
                              f"{speed_mbps:.2f} MB/s | ETA: {eta_hours:.1f}h", 
                              end='\r', flush=True)
                        last_print = current_time
                    
                    # Logger toutes les 5 minutes
                    if current_time - last_log >= 300:
                        percent = (downloaded / total_size) * 100
                        downloaded_gb = downloaded / (1024**3)
                        total_gb = total_size / (1024**3)
                        elapsed = current_time - start_time
                        speed_mbps = (downloaded - resume_byte) / elapsed / (1024**2)
                        
                        log(f"📊 Progression: {percent:.1f}% | {downloaded_gb:.2f}/{total_gb:.2f} GB | "
                            f"Vitesse: {speed_mbps:.2f} MB/s")
                        last_log = current_time
        
        print()
        log("")
        log("=" * 80)
        log("✅ TÉLÉCHARGEMENT TERMINÉ AVEC SUCCÈS")
        log("=" * 80)
        log(f"📁 Fichier: {output_file}")
        log(f"💾 Taille: {output_file.stat().st_size / (1024**3):.2f} GB")
        log(f"⏱️  Durée totale: {(time.time() - start_time) / 3600:.2f} heures")
        log("")
        
        # Créer un fichier marqueur de succès
        success_file = osm_dir / "download_complete.flag"
        success_file.write_text(f"Téléchargement terminé le {time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        return True
        
    except KeyboardInterrupt:
        log("")
        log("⚠️  Téléchargement interrompu par l'utilisateur")
        log(f"📊 {downloaded / (1024**3):.2f} GB téléchargés")
        log("💡 Relancez le script pour reprendre")
        return False
        
    except Exception as e:
        log(f"❌ Erreur: {e}")
        log(f"📊 {downloaded / (1024**3) if 'downloaded' in locals() else 0:.2f} GB téléchargés")
        log("💡 Relancez le script pour reprendre")
        return False


if __name__ == "__main__":
    success = download_osm_planet()
    sys.exit(0 if success else 1)

