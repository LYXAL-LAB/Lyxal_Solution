#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyse complète du contenu d'OSM France.
Sans osmium, on va lire directement le fichier PBF pour comprendre sa structure.
"""

from pathlib import Path
import struct

def analyze_pbf_structure():
    """Analyse la structure du fichier PBF."""
    
    osm_file = Path("osm_data/france-latest.osm.pbf")
    
    if not osm_file.exists():
        print("❌ Fichier introuvable")
        return
    
    print("=" * 80)
    print("ANALYSE DÉTAILLÉE OSM FRANCE")
    print("=" * 80)
    print()
    
    # Informations de base
    file_size_gb = osm_file.stat().st_size / (1024**3)
    print(f"📁 Fichier: {osm_file}")
    print(f"💾 Taille: {file_size_gb:.2f} GB ({osm_file.stat().st_size:,} octets)")
    print()
    
    # Lire l'en-tête PBF
    with open(osm_file, 'rb') as f:
        # Les 4 premiers octets sont la taille du header
        header_size_bytes = f.read(4)
        if len(header_size_bytes) < 4:
            print("❌ Fichier trop petit")
            return
        
        header_size = struct.unpack('>I', header_size_bytes)[0]
        print(f"📋 Header PBF size: {header_size} octets")
        
        # Lire un échantillon pour détecter le type
        f.seek(0)
        sample = f.read(1024)
        
        print()
        print("🔍 Signature du fichier:")
        print(f"   Magic bytes: {sample[:20].hex()}")
        print()
    
    print("=" * 80)
    print("CONTENU OSM - CE QU'ON SAIT")
    print("=" * 80)
    print()
    
    print("📦 Un fichier OSM PBF contient typiquement:")
    print()
    
    print("1️⃣  NODES (Nœuds) 🔴")
    print("   - Points géographiques avec coordonnées lat/lon")
    print("   - Tags: name, amenity, shop, tourism, etc.")
    print("   - Exemples: restaurants, hôtels, monuments, carrefours")
    print("   - Estimation France: ~400-500 millions de nodes")
    print()
    
    print("2️⃣  WAYS (Chemins) 🔵")
    print("   - Lignes ou polygones formés de nodes")
    print("   - Tags: highway, building, boundary, etc.")
    print("   - Exemples: routes, rues, bâtiments, frontières simples")
    print("   - Estimation France: ~50-80 millions de ways")
    print()
    
    print("3️⃣  RELATIONS (Relations) 🟢")
    print("   - Groupes de nodes/ways avec rôles")
    print("   - Tags: boundary=administrative, type=multipolygon, etc.")
    print("   - Exemples: frontières de villes/départements/régions, lignes de bus")
    print("   - Estimation France: ~1-2 millions de relations")
    print()
    
    print("=" * 80)
    print("DONNÉES GÉOGRAPHIQUES DISPONIBLES")
    print("=" * 80)
    print()
    
    print("🗺️  BOUNDARIES ADMINISTRATIVES:")
    print("   ├─ admin_level=2  → Pays (France)")
    print("   ├─ admin_level=3  → Régions métropolitaines")
    print("   ├─ admin_level=4  → Régions")
    print("   ├─ admin_level=5  → Territoires spéciaux")
    print("   ├─ admin_level=6  → Départements")
    print("   ├─ admin_level=7  → Arrondissements")
    print("   ├─ admin_level=8  → Communes/Villes 🎯 (CE QU'ON VEUT)")
    print("   ├─ admin_level=9  → Arrondissements municipaux")
    print("   └─ admin_level=10 → Quartiers")
    print()
    
    print("🚗 RÉSEAU ROUTIER:")
    print("   ├─ highway=motorway     → Autoroutes")
    print("   ├─ highway=trunk        → Routes nationales")
    print("   ├─ highway=primary      → Routes départementales")
    print("   ├─ highway=secondary    → Routes secondaires")
    print("   ├─ highway=tertiary     → Routes tertiaires")
    print("   ├─ highway=residential  → Rues résidentielles")
    print("   └─ highway=...          → Chemins, pistes cyclables, etc.")
    print()
    
    print("📍 POINTS D'INTÉRÊT (POI):")
    print("   ├─ amenity=restaurant   → Restaurants")
    print("   ├─ amenity=hotel        → Hôtels")
    print("   ├─ amenity=fuel         → Stations-service")
    print("   ├─ amenity=hospital     → Hôpitaux")
    print("   ├─ amenity=school       → Écoles")
    print("   ├─ shop=*               → Magasins")
    print("   ├─ tourism=*            → Sites touristiques")
    print("   └─ ... et bien d'autres")
    print()
    
    print("🏢 BÂTIMENTS:")
    print("   └─ building=*           → Tous types de bâtiments")
    print()
    
    print("🌳 ÉLÉMENTS NATURELS:")
    print("   ├─ natural=water        → Plans d'eau")
    print("   ├─ natural=forest       → Forêts")
    print("   └─ waterway=*           → Rivières, canaux")
    print()
    
    print("=" * 80)
    print("ESTIMATION DU CONTENU POUR LA FRANCE")
    print("=" * 80)
    print()
    
    print("📊 Volumes approximatifs:")
    print()
    print(f"   Nodes totaux:          ~400-500 millions")
    print(f"   Ways totaux:           ~50-80 millions")
    print(f"   Relations totales:     ~1-2 millions")
    print()
    print(f"   Communes (admin_8):    ~35,000 boundaries 🎯")
    print(f"   Départements:          ~100 boundaries")
    print(f"   Régions:               ~18 boundaries")
    print()
    print(f"   Routes/rues:           ~5-10 millions de segments")
    print(f"   Restaurants:           ~100,000-200,000")
    print(f"   Hôtels:                ~30,000-50,000")
    print(f"   Bâtiments:             ~20-30 millions")
    print()
    
    print("=" * 80)
    print("STRUCTURE DES TAGS OSM")
    print("=" * 80)
    print()
    
    print("Exemple de BOUNDARY (Commune):")
    print("""
    <relation id="123456">
      <tag k="name" v="Paris"/>
      <tag k="boundary" v="administrative"/>
      <tag k="admin_level" v="8"/>
      <tag k="ref:INSEE" v="75056"/>
      <tag k="population" v="2165423"/>
      <tag k="wikipedia" v="fr:Paris"/>
      <tag k="wikidata" v="Q90"/>
      <member type="way" ref="234567" role="outer"/>
      <member type="way" ref="234568" role="outer"/>
      ...
    </relation>
    """)
    
    print()
    print("Exemple de ROUTE (Rue):")
    print("""
    <way id="987654">
      <tag k="name" v="Avenue des Champs-Élysées"/>
      <tag k="highway" v="primary"/>
      <tag k="maxspeed" v="50"/>
      <tag k="lanes" v="4"/>
      <tag k="oneway" v="yes"/>
      <tag k="surface" v="asphalt"/>
      <nd ref="1234"/>
      <nd ref="1235"/>
      <nd ref="1236"/>
      ...
    </way>
    """)
    
    print()
    print("Exemple de POI (Restaurant):")
    print("""
    <node id="456789" lat="48.8566" lon="2.3522">
      <tag k="name" v="Le Jules Verne"/>
      <tag k="amenity" v="restaurant"/>
      <tag k="cuisine" v="french"/>
      <tag k="stars" v="1"/>
      <tag k="website" v="..."/>
      <tag k="phone" v="+33 1 45 55 61 44"/>
      <tag k="addr:street" v="Tour Eiffel"/>
      <tag k="addr:city" v="Paris"/>
    </node>
    """)
    
    print()
    print("=" * 80)
    print("CORRESPONDANCE AVEC VOS BESOINS")
    print("=" * 80)
    print()
    
    print("✅ POUR VOS CITIES (base_city):")
    print("   → Relations avec admin_level=8 (communes)")
    print("   → ~35,000 entités en France")
    print("   → Contient: nom, INSEE code, population, boundaries (polygones)")
    print()
    
    print("✅ POUR VOS STATES (base_state):")
    print("   → Relations avec admin_level=6 (départements)")
    print("   → ~100 entités en France")
    print("   → Contient: nom, code département, boundaries")
    print()
    
    print("✅ POUR LE GPS/NAVIGATION:")
    print("   → Ways avec highway=* (routes)")
    print("   → Millions de segments de routes")
    print("   → Contient: nom rue, type route, vitesse, sens unique")
    print()
    
    print("✅ POUR LES POI:")
    print("   → Nodes avec amenity=*, shop=*, tourism=*")
    print("   → Centaines de milliers de points")
    print("   → Contient: nom, type, adresse, téléphone, horaires")
    print()
    
    print("=" * 80)
    print("PROCHAINES ÉTAPES POSSIBLES")
    print("=" * 80)
    print()
    
    print("Option A: Extraire UNIQUEMENT les boundaries des communes")
    print("   → Fichier filtré: ~50-100 MB")
    print("   → Temps: 5-10 minutes")
    print("   → Usage: Enrichir vos base_city avec polygones")
    print()
    
    print("Option B: Extraire boundaries + réseau routier")
    print("   → Fichier filtré: ~500 MB - 1 GB")
    print("   → Temps: 15-30 minutes")
    print("   → Usage: Navigation GPS")
    print()
    
    print("Option C: Extraire boundaries + routes + POI")
    print("   → Fichier filtré: ~1-2 GB")
    print("   → Temps: 30-60 minutes")
    print("   → Usage: Système complet")
    print()
    
    print("Option D: Tout garder et requêter directement")
    print("   → Importer dans PostgreSQL + PostGIS")
    print("   → Requêter selon besoins")
    print("   → Plus flexible mais plus lourd")
    print()
    
    print("=" * 80)

if __name__ == "__main__":
    analyze_pbf_structure()

