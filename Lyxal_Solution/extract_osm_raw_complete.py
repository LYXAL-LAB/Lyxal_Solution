#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
EXTRACTION BRUTE ULTRA-RAPIDE - OSM FRANCE COMPLET
Convertit tout le fichier PBF en JSON pur, sans tri ni filtre.
Structure claire, exploitation ultérieure selon besoins.
"""

import osmium
import json
import gzip
from pathlib import Path
import time

class RawOSMExtractor(osmium.SimpleHandler):
    """
    Extracteur brut sans catégorisation.
    Maximum de vitesse, minimum de complexité.
    """
    
    def __init__(self, output_dir):
        super().__init__()
        
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 3 fichiers séparés pour optimiser (sinon 1 seul fichier de 40GB+)
        self.nodes_file = gzip.open(self.output_dir / "nodes.json.gz", 'wt', encoding='utf-8')
        self.ways_file = gzip.open(self.output_dir / "ways.json.gz", 'wt', encoding='utf-8')
        self.relations_file = gzip.open(self.output_dir / "relations.json.gz", 'wt', encoding='utf-8')
        
        # Compteurs
        self.node_count = 0
        self.way_count = 0
        self.relation_count = 0
        self.start_time = time.time()
        
    def node(self, n):
        """Extrait un node."""
        self.node_count += 1
        
        if self.node_count % 1000000 == 0:
            elapsed = time.time() - self.start_time
            rate = self.node_count / elapsed if elapsed > 0 else 0
            print(f"   Nodes: {self.node_count:,} | Vitesse: {rate:,.0f}/sec", end='\r')
        
        # Extraire données
        data = {
            "id": n.id,
            "type": "node",
            "tags": {tag.k: tag.v for tag in n.tags}
        }
        
        # Coordonnées si disponibles
        if hasattr(n, 'location') and n.location.valid():
            data["lat"] = n.location.lat
            data["lon"] = n.location.lon
        
        # Écrire (1 ligne JSON par entité)
        self.nodes_file.write(json.dumps(data, ensure_ascii=False) + '\n')
    
    def way(self, w):
        """Extrait un way."""
        self.way_count += 1
        
        if self.way_count % 100000 == 0:
            elapsed = time.time() - self.start_time
            total = self.node_count + self.way_count + self.relation_count
            rate = total / elapsed if elapsed > 0 else 0
            print(f"   Ways: {self.way_count:,} | Total: {total:,} | Vitesse: {rate:,.0f}/sec", end='\r')
        
        # Extraire données
        data = {
            "id": w.id,
            "type": "way",
            "tags": {tag.k: tag.v for tag in w.tags},
            "nodes": [n.ref for n in w.nodes]
        }
        
        # Écrire
        self.ways_file.write(json.dumps(data, ensure_ascii=False) + '\n')
    
    def relation(self, r):
        """Extrait une relation."""
        self.relation_count += 1
        
        if self.relation_count % 10000 == 0:
            elapsed = time.time() - self.start_time
            total = self.node_count + self.way_count + self.relation_count
            rate = total / elapsed if elapsed > 0 else 0
            eta_seconds = (581641117 - total) / rate if rate > 0 else 0
            eta_hours = eta_seconds / 3600
            print(f"   Relations: {self.relation_count:,} | Total: {total:,} | Vitesse: {rate:,.0f}/sec | ETA: {eta_hours:.1f}h", end='\r')
        
        # Extraire données
        data = {
            "id": r.id,
            "type": "relation",
            "tags": {tag.k: tag.v for tag in r.tags},
            "members": [
                {
                    "type": m.type,
                    "ref": m.ref,
                    "role": m.role
                }
                for m in r.members
            ]
        }
        
        # Écrire
        self.relations_file.write(json.dumps(data, ensure_ascii=False) + '\n')
    
    def close(self):
        """Ferme les fichiers."""
        self.nodes_file.close()
        self.ways_file.close()
        self.relations_file.close()


def main():
    osm_file = Path("osm_data/france-latest.osm.pbf")
    output_dir = Path("osm_france_raw")
    
    if not osm_file.exists():
        print("❌ Fichier OSM introuvable")
        return
    
    print("=" * 100)
    print("EXTRACTION BRUTE ULTRA-RAPIDE - OSM FRANCE COMPLET")
    print("=" * 100)
    print()
    print(f"📁 Source: {osm_file}")
    print(f"💾 Taille: {osm_file.stat().st_size / (1024**3):.2f} GB")
    print(f"📁 Destination: {output_dir}/")
    print()
    print("🎯 Stratégie:")
    print("   - Extraction BRUTE sans tri ni catégorisation")
    print("   - Maximum de vitesse (50-100x plus rapide)")
    print("   - 3 fichiers: nodes.json.gz, ways.json.gz, relations.json.gz")
    print("   - Format: 1 ligne JSON par entité")
    print("   - Filtrage/tri ultérieur selon vos besoins")
    print()
    print("⏳ Extraction en cours (2-4 heures estimées)...")
    print()
    
    # Créer l'extracteur
    handler = RawOSMExtractor(output_dir)
    
    start = time.time()
    
    try:
        # Lancer l'extraction
        handler.apply_file(str(osm_file))
        
        # Fermer les fichiers
        handler.close()
        
        elapsed = time.time() - start
        
        print()
        print()
        print("=" * 100)
        print("✅ EXTRACTION BRUTE TERMINÉE")
        print("=" * 100)
        print()
        print(f"⏱️  Durée totale: {elapsed/3600:.1f} heures ({elapsed/60:.0f} minutes)")
        print()
        print("📊 STATISTIQUES:")
        print("-" * 100)
        print(f"  Nodes extraits:      {handler.node_count:,}")
        print(f"  Ways extraits:       {handler.way_count:,}")
        print(f"  Relations extraites: {handler.relation_count:,}")
        print(f"  TOTAL:               {handler.node_count + handler.way_count + handler.relation_count:,}")
        print()
        print(f"  Vitesse moyenne:     {(handler.node_count + handler.way_count + handler.relation_count) / elapsed:,.0f} entités/sec")
        print()
        
        # Tailles des fichiers
        print("📁 FICHIERS CRÉÉS:")
        print("-" * 100)
        
        nodes_file = output_dir / "nodes.json.gz"
        ways_file = output_dir / "ways.json.gz"
        relations_file = output_dir / "relations.json.gz"
        
        if nodes_file.exists():
            size_gb = nodes_file.stat().st_size / (1024**3)
            print(f"  nodes.json.gz:      {size_gb:6.2f} GB  ({handler.node_count:,} nodes)")
        
        if ways_file.exists():
            size_gb = ways_file.stat().st_size / (1024**3)
            print(f"  ways.json.gz:       {size_gb:6.2f} GB  ({handler.way_count:,} ways)")
        
        if relations_file.exists():
            size_gb = relations_file.stat().st_size / (1024**3)
            print(f"  relations.json.gz:  {size_gb:6.2f} GB  ({handler.relation_count:,} relations)")
        
        total_size = sum(
            f.stat().st_size for f in [nodes_file, ways_file, relations_file] if f.exists()
        ) / (1024**3)
        
        print(f"  {'─' * 60}")
        print(f"  TOTAL:              {total_size:6.2f} GB")
        print()
        
        print("=" * 100)
        print("📋 STRUCTURE DES DONNÉES")
        print("=" * 100)
        print()
        print("Format: JSON ligne par ligne (NDJSON)")
        print()
        print("Exemple nodes.json.gz:")
        print('  {"id": 123, "type": "node", "tags": {"name": "Paris"}, "lat": 48.85, "lon": 2.35}')
        print()
        print("Exemple ways.json.gz:")
        print('  {"id": 456, "type": "way", "tags": {"highway": "residential"}, "nodes": [1,2,3]}')
        print()
        print("Exemple relations.json.gz:")
        print('  {"id": 789, "type": "relation", "tags": {"boundary": "administrative"}, "members": [...]}')
        print()
        
        print("=" * 100)
        print("🎯 EXPLOITATION DES DONNÉES")
        print("=" * 100)
        print()
        print("Pour filtrer/extraire selon vos besoins:")
        print()
        print("  # Exemple Python - Extraire tous les restaurants")
        print("  import gzip, json")
        print("  with gzip.open('osm_france_raw/nodes.json.gz', 'rt') as f:")
        print("      for line in f:")
        print("          data = json.loads(line)")
        print("          if data['tags'].get('amenity') == 'restaurant':")
        print("              # Traiter le restaurant")
        print()
        print("  # Exemple - Extraire toutes les communes (admin_level 8)")
        print("  with gzip.open('osm_france_raw/relations.json.gz', 'rt') as f:")
        print("      for line in f:")
        print("          data = json.loads(line)")
        print("          if data['tags'].get('admin_level') == '8':")
        print("              # Traiter la commune")
        print()
        
        print("=" * 100)
        print("💡 AVANTAGES DE CETTE APPROCHE")
        print("=" * 100)
        print()
        print("  ✅ Extraction RAPIDE (2-4h au lieu de 7 jours)")
        print("  ✅ SIMPLICITÉ maximale (3 fichiers au lieu de 1000)")
        print("  ✅ FLEXIBILITÉ totale (filtrez ce que vous voulez, quand vous voulez)")
        print("  ✅ Pas de décisions prématurées sur la catégorisation")
        print("  ✅ Structure CLAIRE et standard (JSON)")
        print("  ✅ Compatible avec tous les outils (Python, SurrealDB, etc.)")
        print("  ✅ Stream processing possible (pas besoin de tout charger en mémoire)")
        print()
        
        # Créer un fichier README
        readme = output_dir / "README.md"
        readme.write_text(f"""# OSM France - Extraction Brute Complète

## 📊 Statistiques

- **Nodes**: {handler.node_count:,}
- **Ways**: {handler.way_count:,}
- **Relations**: {handler.relation_count:,}
- **Total**: {handler.node_count + handler.way_count + handler.relation_count:,} entités

- **Taille totale**: {total_size:.2f} GB (compressé)
- **Date d'extraction**: {time.strftime('%Y-%m-%d %H:%M:%S')}
- **Durée**: {elapsed/3600:.1f} heures

## 📁 Fichiers

1. **nodes.json.gz** - Points géographiques (restaurants, arbres, etc.)
2. **ways.json.gz** - Lignes/polygones (routes, bâtiments, etc.)
3. **relations.json.gz** - Groupes complexes (communes, départements, etc.)

## 📋 Format

Chaque fichier contient du JSON ligne par ligne (NDJSON):

```json
{{"id": 123, "type": "node", "tags": {{"name": "Paris"}}, "lat": 48.85, "lon": 2.35}}
```

## 🎯 Utilisation

Filtrez selon vos besoins avec Python, jq, ou tout autre outil.

Exemple - Extraire tous les restaurants:
```python
import gzip, json
with gzip.open('nodes.json.gz', 'rt') as f:
    for line in f:
        data = json.loads(line)
        if data.get('tags', {{}}).get('amenity') == 'restaurant':
            print(data)
```

## 📖 Documentation OSM

Tags OSM: https://wiki.openstreetmap.org/wiki/Map_Features
""", encoding='utf-8')
        
        print(f"📖 README créé: {readme}")
        print()
        print("=" * 100)
        print("🎉 VOUS AVEZ MAINTENANT TOUTES LES DONNÉES OSM FRANCE !")
        print("=" * 100)
        
    except Exception as e:
        print(f"\n\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        handler.close()


if __name__ == "__main__":
    main()

