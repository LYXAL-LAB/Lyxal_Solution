#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyse si le fichier source cities.json.gz contient des données de boundaries.
"""

import gzip
import json

def main():
    source_file = "temp_cities_db/json/cities.json.gz"
    
    print("🔍 Analyse du fichier source cities.json.gz pour les boundaries...")
    print()
    
    # Analyser les premières villes pour voir la structure
    sample_cities = []
    cities_with_boundary = 0
    total_checked = 0
    
    with gzip.open(source_file, 'rt', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            if line_num % 100000 == 0:
                print(f"Analyse... {line_num:,} lignes", end='\r')
            
            try:
                city = json.loads(line.strip())
                total_checked += 1
                
                # Garder quelques exemples pour analyse
                if len(sample_cities) < 5:
                    sample_cities.append(city)
                
                # Vérifier les champs potentiels de boundary
                has_boundary = False
                boundary_fields = []
                
                for key in city.keys():
                    if any(keyword in key.lower() for keyword in ['bound', 'polygon', 'geometry', 'shape', 'area', 'border']):
                        boundary_fields.append(key)
                        has_boundary = True
                
                if has_boundary:
                    cities_with_boundary += 1
                
                # Arrêter après un échantillon suffisant
                if line_num > 1000000:
                    break
                    
            except Exception as e:
                continue
    
    print("\n")
    print("=" * 80)
    print("ANALYSE DES BOUNDARIES DANS LA SOURCE")
    print("=" * 80)
    print()
    
    print(f"📊 Villes analysées: {total_checked:,}")
    print(f"🗺️  Villes avec champs boundary: {cities_with_boundary:,}")
    print()
    
    # Afficher la structure d'une ville exemple
    if sample_cities:
        print("📋 STRUCTURE D'UNE VILLE EXEMPLE:")
        print("-" * 80)
        city = sample_cities[0]
        print(f"Ville: {city.get('name', 'N/A')}, {city.get('country_code', 'N/A')}")
        print()
        print("Champs disponibles:")
        for key in sorted(city.keys()):
            value = city[key]
            if isinstance(value, (dict, list)) and len(str(value)) > 100:
                print(f"  - {key}: {type(value).__name__} (taille: {len(str(value))} chars)")
            else:
                print(f"  - {key}: {value}")
    
    print()
    print("=" * 80)
    print("CONCLUSION:")
    print("=" * 80)
    
    if cities_with_boundary > 0:
        print(f"✅ {cities_with_boundary:,} villes ont des données de boundaries!")
        print("   → Nous pouvons les extraire et les importer.")
    else:
        print("⚠️  Le fichier cities.json.gz ne contient pas de données de boundaries.")
        print("   → Il faut chercher une autre source (OpenStreetMap, geojson-places, etc.)")
    print("=" * 80)

if __name__ == "__main__":
    main()

