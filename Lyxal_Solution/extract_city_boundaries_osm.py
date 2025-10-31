#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extraction des boundaries de villes depuis OpenStreetMap Overpass API.
Stratégie: Extraction progressive par pays pour éviter les timeouts.
"""

import requests
import json
import time
from pathlib import Path
import gzip
from collections import defaultdict

class OSMCityBoundaryExtractor:
    """
    Extracteur de boundaries de villes depuis OpenStreetMap.
    """
    
    def __init__(self):
        self.overpass_url = "https://overpass-api.de/api/interpreter"
        self.cache_dir = Path("Lyxal_Solution/osm_boundaries_cache")
        self.cache_dir.mkdir(exist_ok=True)
        
    def load_our_cities(self):
        """Charge toutes nos villes depuis cities.json.gz"""
        print("📂 Chargement de nos villes...")
        
        cities_by_country = defaultdict(list)
        
        with gzip.open("temp_cities_db/json/cities.json.gz", 'rt', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                if line_num % 100000 == 0:
                    print(f"   Lecture... {line_num:,} villes", end='\r')
                
                try:
                    city = json.loads(line.strip())
                    country_code = city.get('country_code', '').lower()
                    city_name = city.get('name', '')
                    city_id = city.get('id', 0)
                    lat = city.get('latitude')
                    lon = city.get('longitude')
                    
                    if country_code and city_name and lat and lon:
                        cities_by_country[country_code].append({
                            'id': city_id,
                            'name': city_name,
                            'lat': lat,
                            'lon': lon
                        })
                except:
                    continue
        
        print(f"\n✅ {sum(len(v) for v in cities_by_country.values()):,} villes dans {len(cities_by_country)} pays")
        return cities_by_country
    
    def build_overpass_query(self, country_code, city_name, lat, lon):
        """
        Construit une requête Overpass pour trouver la boundary d'une ville.
        """
        # Chercher dans un rayon de ~50km autour des coordonnées
        bbox_size = 0.5  # ~50km
        south = lat - bbox_size
        north = lat + bbox_size
        west = lon - bbox_size
        east = lon + bbox_size
        
        query = f"""
        [out:json][timeout:30];
        (
          // Chercher les relations avec boundary=administrative
          relation["boundary"="administrative"]["admin_level"~"^(8|9|10)$"]["name"~"{city_name}",i]({south},{west},{north},{east});
          
          // Aussi chercher les ways (polygones simples)
          way["boundary"="administrative"]["admin_level"~"^(8|9|10)$"]["name"~"{city_name}",i]({south},{west},{north},{east});
        );
        out geom;
        """
        
        return query
    
    def query_overpass(self, query):
        """Exécute une requête Overpass."""
        try:
            response = requests.post(
                self.overpass_url,
                data={'data': query},
                timeout=60
            )
            
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 429:
                print("⚠️  Rate limit - attente 60s...")
                time.sleep(60)
                return None
            else:
                return None
                
        except Exception as e:
            print(f"❌ Erreur: {e}")
            return None
    
    def convert_osm_to_geojson(self, osm_data):
        """
        Convertit les données OSM en GeoJSON MultiPolygon.
        """
        if not osm_data or 'elements' not in osm_data:
            return None
        
        elements = osm_data['elements']
        if not elements:
            return None
        
        # Prendre le premier élément (généralement le plus pertinent)
        element = elements[0]
        
        try:
            if element['type'] == 'relation':
                # Extraire les polygones de la relation
                coordinates = []
                
                for member in element.get('members', []):
                    if member['type'] == 'way' and member.get('role') == 'outer':
                        way_coords = []
                        for node in member.get('geometry', []):
                            way_coords.append([node['lon'], node['lat']])
                        
                        if way_coords and way_coords[0] != way_coords[-1]:
                            way_coords.append(way_coords[0])
                        
                        if len(way_coords) >= 4:
                            coordinates.append([way_coords])
                
                if coordinates:
                    return {
                        'type': 'MultiPolygon',
                        'coordinates': coordinates
                    }
            
            elif element['type'] == 'way':
                # Polygone simple
                coords = []
                for node in element.get('geometry', []):
                    coords.append([node['lon'], node['lat']])
                
                if coords and coords[0] != coords[-1]:
                    coords.append(coords[0])
                
                if len(coords) >= 4:
                    return {
                        'type': 'MultiPolygon',
                        'coordinates': [[coords]]
                    }
        except Exception as e:
            print(f"⚠️  Erreur conversion: {e}")
            return None
        
        return None
    
    def extract_boundaries_for_country(self, country_code, cities, max_cities=100):
        """
        Extrait les boundaries pour les villes d'un pays.
        """
        print(f"\n🌍 Traitement: {country_code.upper()} ({len(cities)} villes)")
        
        cache_file = self.cache_dir / f"{country_code}_boundaries.json"
        
        # Charger depuis le cache si existe
        if cache_file.exists():
            print(f"   ✅ Chargé depuis cache")
            with open(cache_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        
        boundaries = {}
        
        # Limiter pour éviter les abus
        cities_to_process = cities[:max_cities]
        
        for idx, city in enumerate(cities_to_process, 1):
            print(f"   [{idx}/{len(cities_to_process)}] {city['name']}...", end='\r')
            
            # Construire et exécuter la requête
            query = self.build_overpass_query(
                country_code,
                city['name'],
                city['lat'],
                city['lon']
            )
            
            osm_data = self.query_overpass(query)
            
            if osm_data:
                boundary = self.convert_osm_to_geojson(osm_data)
                
                if boundary:
                    boundaries[city['id']] = {
                        'name': city['name'],
                        'boundary': boundary
                    }
            
            # Respecter les limites de l'API
            time.sleep(1)
        
        print(f"\n   ✅ {len(boundaries)} boundaries trouvées")
        
        # Sauvegarder dans le cache
        with open(cache_file, 'w', encoding='utf-8') as f:
            json.dump(boundaries, f, ensure_ascii=False, indent=2)
        
        return boundaries
    
    def run(self, countries_to_process=None, max_cities_per_country=50):
        """
        Exécute l'extraction pour les pays spécifiés.
        """
        print("=" * 80)
        print("EXTRACTION DES BOUNDARIES DE VILLES DEPUIS OPENSTREETMAP")
        print("=" * 80)
        print()
        
        # Charger nos villes
        cities_by_country = self.load_our_cities()
        
        if countries_to_process:
            countries = countries_to_process
        else:
            # Par défaut: top 10 pays par nombre de villes
            countries = sorted(
                cities_by_country.keys(),
                key=lambda k: len(cities_by_country[k]),
                reverse=True
            )[:10]
        
        print(f"\n🎯 Pays à traiter: {', '.join(c.upper() for c in countries)}")
        print(f"📊 Max {max_cities_per_country} villes par pays")
        print()
        
        all_boundaries = {}
        
        for country_code in countries:
            if country_code not in cities_by_country:
                continue
            
            boundaries = self.extract_boundaries_for_country(
                country_code,
                cities_by_country[country_code],
                max_cities=max_cities_per_country
            )
            
            all_boundaries[country_code] = boundaries
        
        print()
        print("=" * 80)
        print("RÉCAPITULATIF")
        print("=" * 80)
        
        total_boundaries = sum(len(b) for b in all_boundaries.values())
        print(f"✅ {total_boundaries} boundaries extraites")
        print(f"📁 Cache: {self.cache_dir}")
        print()
        print("💡 Pour appliquer ces boundaries aux fichiers seeds, exécuter:")
        print("   python apply_city_boundaries.py")
        print("=" * 80)
        
        return all_boundaries


def main():
    print("🚀 Démarrage de l'extraction...")
    print()
    print("⚠️  IMPORTANT:")
    print("   - Cette extraction peut prendre plusieurs heures")
    print("   - Respecte les limites de l'API Overpass (1 req/sec)")
    print("   - Les résultats sont mis en cache pour éviter les re-téléchargements")
    print()
    
    extractor = OSMCityBoundaryExtractor()
    
    # TEST: Extraire pour quelques pays seulement
    test_countries = ['fr', 'us', 'de', 'it', 'es']
    
    extractor.run(
        countries_to_process=test_countries,
        max_cities_per_country=10  # Limité à 10 villes par pays pour le test
    )


if __name__ == "__main__":
    main()

