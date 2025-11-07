#!/usr/bin/env python3
"""
Script pour télécharger des SVGs depuis des URLs et les uploader vers Bunny Storage
"""

import os
import sys
import requests
import logging
import json
from urllib.parse import urlparse
from pathlib import Path

# Configuration Bunny Storage
BUNNY_API_KEY = "2e89ed19-65af-4d73-a27fe83cb3b1-3655-4974"
BUNNY_STORAGE_ZONE = "lyxalsolution"  # Storage zone configurée
BUNNY_REGION = ""  # Région Allemagne (DE) = chaîne vide selon la doc Bunny

# Configuration des logs
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('upload_svgs.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

def download_svg(url, timeout=30):
    """
    Télécharge un fichier SVG depuis une URL
    """
    try:
        response = requests.get(url, timeout=timeout)
        response.raise_for_status()

        # Vérifier que c'est bien un SVG
        content_type = response.headers.get('content-type', '').lower()
        if 'svg' not in content_type and not response.text.strip().startswith('<svg'):
            logging.warning(f"L'URL {url} ne semble pas pointer vers un SVG (content-type: {content_type})")
            return None

        return response.content
    except requests.RequestException as e:
        logging.error(f"Erreur lors du téléchargement de {url}: {e}")
        return None

def upload_to_bunny(file_content, filename, storage_zone, api_key, region):
    """
    Upload un fichier vers Bunny Storage selon l'API officielle
    """
    # Construction de l'URL selon la documentation Bunny
    base_url = "storage.bunnycdn.com"
    if region:
        base_url = f"{region}.{base_url}"

    url = f"https://{base_url}/{storage_zone}/{filename}"

    headers = {
        "AccessKey": api_key,
        "Content-Type": "application/octet-stream",  # Type générique selon la doc Bunny
        "accept": "application/json"
    }

    try:
        response = requests.put(url, data=file_content, headers=headers)
        response.raise_for_status()

        logging.info(f"Fichier {filename} uploadé avec succès vers {url}")
        return True
    except requests.RequestException as e:
        logging.error(f"Erreur lors de l'upload de {filename}: {e}")
        return False

def get_filename_from_url(url, custom_name=None):
    """
    Extrait un nom de fichier depuis une URL ou utilise un nom personnalisé
    """
    if custom_name:
        filename = f"{custom_name}.svg"
    else:
        parsed_url = urlparse(url)
        filename = os.path.basename(parsed_url.path)

        # Si pas d'extension, ajouter .svg
        if not filename or '.' not in filename:
            filename = f"svg_{hash(url) % 10000}.svg"

        # S'assurer que c'est bien une extension SVG
        if not filename.lower().endswith('.svg'):
            filename = filename.rsplit('.', 1)[0] + '.svg'

    return filename

def load_keys_from_json(json_file_path):
    """
    Charge seulement les clés depuis le fichier JSON pour traitement à la volée
    """
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return list(data.keys())
    except Exception as e:
        logging.error(f"Erreur lors du chargement du fichier JSON {json_file_path}: {e}")
        return []

def process_file(file_path, storage_zone, api_key, region, dry_run=False):
    """
    Traite un fichier contenant des URLs (format texte ou JSON)
    """
    if not os.path.exists(file_path):
        logging.error(f"Le fichier {file_path} n'existe pas")
        return

    success_count = 0
    error_count = 0
    processed_count = 0

    # Détecter le type de fichier
    if file_path.lower().endswith('.json'):
        # Traitement du fichier JSON - chargement des clés seulement
        # Utiliser le svgs.json du repo complet si on utilise svgs.json depuis la racine
        json_path = "svg-logos/svgs.json" if file_path == "svgs.json" else file_path
        keys = load_keys_from_json(json_path)
        total_files = len(keys)
        logging.info(f"Traitement de {total_files} logos depuis {file_path}")
        logging.info("=" * 80)
        logging.info("DEBUT DU TRAITEMENT DES LOGOS")
        logging.info("=" * 80)

        for key in keys:
            processed_count += 1
            filename = f"assets/logos/{key}.svg"

            # Essayer d'abord de lire le fichier SVG local
            first_char = key[0].lower() if key else 'a'
            local_svg_path = f"svg-logos/svg/{first_char}/{key}.svg"

            if os.path.exists(local_svg_path):
                # Lire le contenu du fichier local
                try:
                    with open(local_svg_path, 'rb') as svg_file:
                        svg_content = svg_file.read()
                    source = 'local'
                    logging.info(f"[{processed_count}/{total_files}] Traitement de {filename} depuis {source}")
                except Exception as e:
                    logging.warning(f"Impossible de lire le fichier local {local_svg_path}: {e}")
                    error_count += 1
                    continue
            else:
                # Fichier local non trouvé - essayer l'URL distante
                # Pour cela on devrait charger les métadonnées depuis le JSON
                # Mais pour simplifier, on passe ce fichier pour l'instant
                logging.warning(f"[{processed_count}/{total_files}] Fichier local non trouvé: {local_svg_path}")
                error_count += 1
                continue

            if dry_run:
                # Mode test : simuler l'upload
                base_url = "storage.bunnycdn.com"
                if region:
                    base_url = f"{region}.{base_url}"
                logging.info(f"[DRY-RUN] [{processed_count}/{total_files}] Simulation upload vers https://{base_url}/{storage_zone}/{filename}")
                success_count += 1
            else:
                # Uploader vers Bunny
                if upload_to_bunny(svg_content, filename, storage_zone, api_key, region):
                    success_count += 1
                    logging.info(f"SUCCES [{processed_count}/{total_files}]: {filename}")
                else:
                    error_count += 1
                    logging.error(f"ECHEC [{processed_count}/{total_files}]: {filename}")

            # Log de progression tous les 100 fichiers
            if processed_count % 100 == 0:
                progress_percent = (processed_count / total_files) * 100
                logging.info("=" * 80)
                logging.info(f"PROGRESSION: {processed_count}/{total_files} fichiers traités ({progress_percent:.1f}%)")
                logging.info(f"SUCCES: {success_count} | ECHECS: {error_count}")
                logging.info("=" * 80)
    else:
        # Traitement du fichier texte (une URL par ligne)
        with open(file_path, 'r', encoding='utf-8') as f:
            urls = [line.strip() for line in f if line.strip() and not line.startswith('#')]

        logging.info(f"Traitement de {len(urls)} URLs depuis {file_path}")

        for url in urls:
            logging.info(f"Traitement de l'URL: {url}")

            # Télécharger le SVG
            svg_content = download_svg(url)
            if svg_content is None:
                error_count += 1
                continue

            # Générer le nom de fichier
            filename = get_filename_from_url(url)

            if dry_run:
                # Mode test : simuler l'upload
                base_url = "storage.bunnycdn.com"
                if region:
                    base_url = f"{region}.{base_url}"
                logging.info(f"[DRY-RUN] Simulation upload de {filename} vers https://{base_url}/{storage_zone}/")
                success_count += 1
            else:
                # Uploader vers Bunny
                if upload_to_bunny(svg_content, filename, storage_zone, api_key, region):
                    success_count += 1
                else:
                    error_count += 1

        # Log final avec résumé complet
        logging.info("=" * 80)
        logging.info("TRAITEMENT TERMINE !")
        logging.info("=" * 80)
        logging.info(f"TOTAL TRAITE: {processed_count} fichiers")
        logging.info(f"REUSSIS: {success_count} fichiers")
        logging.info(f"ECHECS: {error_count} fichiers")
        logging.info(f"TAUX DE REUSSITE: {(success_count/processed_count*100):.1f}%" if processed_count > 0 else "0%")
        logging.info("=" * 80)

def main():
    """
    Fonction principale
    """
    import argparse

    parser = argparse.ArgumentParser(description='Télécharger des SVGs et les uploader vers Bunny Storage')
    parser.add_argument('urls_file', help='Fichier contenant les URLs (texte: une par ligne, ou JSON: format {"key": {"logo": "url"}})')
    parser.add_argument('--storage-zone', default=BUNNY_STORAGE_ZONE,
                       help='Nom de la storage zone Bunny')
    parser.add_argument('--region', default=BUNNY_REGION,
                       help='Région Bunny Storage (vide pour DE, ou ex: la, ny)')
    parser.add_argument('--api-key', default=BUNNY_API_KEY,
                       help='Clé API Bunny Storage')
    parser.add_argument('--dry-run', action='store_true',
                       help='Mode test : simule les opérations sans uploader')

    args = parser.parse_args()

    # Vérifier que la storage zone est configurée
    if args.storage_zone == "votre-storage-zone":
        logging.error("Veuillez configurer le nom de votre storage zone Bunny")
        logging.error("Utilisez --storage-zone VOTRE_ZONE ou modifiez la variable BUNNY_STORAGE_ZONE dans le script")
        sys.exit(1)

    if args.dry_run:
        logging.info("MODE TEST - Simulation d'upload des SVGs vers Bunny Storage")
    else:
        logging.info("Demarrage du processus d'upload des SVGs vers Bunny Storage")

    logging.info(f"Storage Zone: {args.storage_zone}")
    logging.info(f"Région: {args.region or 'DE (Allemagne)'}")

    process_file(args.urls_file, args.storage_zone, args.api_key, args.region, args.dry_run)

if __name__ == "__main__":
    main()
