#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
EXTRACTION COMPLÈTE EN MODE MIROIR - TOUTES LES DONNÉES OSM FRANCE
Crée une copie conforme organisée par domaines et tables.
"""

import osmium
import json
from pathlib import Path
from collections import defaultdict
import gzip

class OSMCompleteMirrorExtractor(osmium.SimpleHandler):
    """
    Extrait TOUTES les données OSM et les organise en structure miroir.
    """
    
    def __init__(self, output_base_dir):
        super().__init__()
        
        self.output_base = Path(output_base_dir)
        self.output_base.mkdir(parents=True, exist_ok=True)
        
        # Compteurs
        self.processed = 0
        self.stats = defaultdict(int)
        
        # Buffer par catégorie (pour écriture par batch)
        self.buffers = defaultdict(list)
        self.buffer_size = 10000  # Écrire toutes les 10k entités
        
        # Mapping domaine -> tags principaux
        self.domain_mappings = {
            "administratif": ["boundary", "admin_level", "postal_code"],
            "transport": ["highway", "railway", "public_transport", "route", "aeroway"],
            "amenities": ["amenity"],
            "commerce": ["shop"],
            "tourisme": ["tourism", "historic"],
            "batiments": ["building"],
            "nature": ["natural", "landuse", "leisure"],
            "infrastructure": ["power", "man_made"],
            "eau": ["waterway", "water"],
            "sante": ["healthcare"],
            "sport": ["sport"],
        }
        
        # Créer la structure de dossiers
        self._create_directory_structure()
    
    def _create_directory_structure(self):
        """Crée l'arborescence de dossiers."""
        for domain in self.domain_mappings.keys():
            (self.output_base / domain).mkdir(exist_ok=True)
        
        # Dossier pour les non-catégorisés
        (self.output_base / "autres").mkdir(exist_ok=True)
    
    def _categorize_entity(self, tags_dict):
        """Détermine la catégorie d'une entité selon ses tags."""
        categories = set()
        
        for domain, tag_keys in self.domain_mappings.items():
            for tag_key in tag_keys:
                if tag_key in tags_dict:
                    categories.add(domain)
        
        if not categories:
            categories.add("autres")
        
        return list(categories)
    
    def _extract_entity_data(self, entity, entity_type):
        """Extrait les données d'une entité OSM."""
        data = {
            "osm_id": entity.id,
            "type": entity_type,
            "tags": {}
        }
        
        # Tags
        for tag in entity.tags:
            data["tags"][tag.k] = tag.v
        
        # Coordonnées pour nodes
        if entity_type == "node" and hasattr(entity, 'location'):
            data["location"] = {
                "lat": entity.location.lat,
                "lon": entity.location.lon
            }
        
        # Nodes pour ways
        if entity_type == "way" and hasattr(entity, 'nodes'):
            data["nodes"] = [n.ref for n in entity.nodes]
        
        # Membres pour relations
        if entity_type == "relation" and hasattr(entity, 'members'):
            data["members"] = []
            for member in entity.members:
                data["members"].append({
                    "type": member.type,
                    "ref": member.ref,
                    "role": member.role
                })
        
        return data
    
    def _write_buffer(self, domain, table_name):
        """Écrit un buffer dans un fichier."""
        key = f"{domain}:{table_name}"
        if key not in self.buffers or len(self.buffers[key]) == 0:
            return
        
        output_file = self.output_base / domain / f"{table_name}.json.gz"
        
        # Append mode
        mode = 'at' if output_file.exists() else 'wt'
        
        with gzip.open(output_file, mode, encoding='utf-8') as f:
            for entity_data in self.buffers[key]:
                f.write(json.dumps(entity_data, ensure_ascii=False) + '\n')
        
        # Vider le buffer
        self.buffers[key] = []
    
    def _add_to_buffer(self, domain, table_name, entity_data):
        """Ajoute une entité au buffer."""
        key = f"{domain}:{table_name}"
        self.buffers[key].append(entity_data)
        
        # Écrire si buffer plein
        if len(self.buffers[key]) >= self.buffer_size:
            self._write_buffer(domain, table_name)
    
    def _process_entity(self, entity, entity_type):
        """Traite une entité."""
        self.processed += 1
        
        if self.processed % 1000000 == 0:
            print(f"   Traité: {self.processed:,} entités...", end='\r')
        
        # Extraire les données
        entity_data = self._extract_entity_data(entity, entity_type)
        
        if not entity_data["tags"]:
            return  # Ignorer les entités sans tags
        
        # Catégoriser
        categories = self._categorize_entity(entity_data["tags"])
        
        # Déterminer le nom de table
        # Utiliser le tag principal comme nom de table
        table_name = "mixed"
        
        for tag_key, tag_value in entity_data["tags"].items():
            if tag_key in ["boundary", "highway", "amenity", "shop", "tourism", 
                           "building", "natural", "landuse", "waterway", "healthcare"]:
                table_name = f"{tag_key}_{tag_value}".replace(":", "_").replace(" ", "_")
                break
        
        # Ajouter aux buffers
        for domain in categories:
            self._add_to_buffer(domain, table_name, entity_data)
            self.stats[f"{domain}:{table_name}"] += 1
    
    def node(self, n):
        """Traite un node."""
        if len(n.tags) > 0:
            self._process_entity(n, "node")
    
    def way(self, w):
        """Traite un way."""
        if len(w.tags) > 0:
            self._process_entity(w, "way")
    
    def relation(self, r):
        """Traite une relation."""
        if len(r.tags) > 0:
            self._process_entity(r, "relation")
    
    def flush_all_buffers(self):
        """Vide tous les buffers."""
        print("\n\n💾 Écriture des derniers buffers...")
        for key in list(self.buffers.keys()):
            domain, table_name = key.split(":", 1)
            self._write_buffer(domain, table_name)
        print("✅ Tous les buffers écrits")


def main():
    osm_file = Path("osm_data/france-latest.osm.pbf")
    output_dir = Path("osm_mirror_france")
    
    if not osm_file.exists():
        print("❌ Fichier OSM introuvable")
        return
    
    print("=" * 100)
    print("EXTRACTION COMPLÈTE EN MODE MIROIR - OSM FRANCE")
    print("=" * 100)
    print()
    print(f"📁 Source: {osm_file}")
    print(f"📁 Destination: {output_dir}/")
    print(f"💾 Taille source: {osm_file.stat().st_size / (1024**3):.2f} GB")
    print()
    print("⏳ Extraction en cours (30-60 minutes)...")
    print("   Toutes les données seront organisées par domaines et tables")
    print()
    
    # Créer l'extracteur
    handler = OSMCompleteMirrorExtractor(output_dir)
    
    try:
        # Lancer l'extraction
        handler.apply_file(str(osm_file))
        
        # Vider tous les buffers
        handler.flush_all_buffers()
        
        print()
        print()
        print("=" * 100)
        print("✅ EXTRACTION MIROIR TERMINÉE")
        print("=" * 100)
        print()
        print(f"📊 Entités traitées: {handler.processed:,}")
        print(f"📁 Dossier de sortie: {output_dir}/")
        print()
        
        # Statistiques par domaine
        print("📋 RÉSUMÉ PAR DOMAINE:")
        print("-" * 100)
        
        domain_totals = defaultdict(int)
        for key, count in handler.stats.items():
            domain = key.split(":")[0]
            domain_totals[domain] += count
        
        for domain, total in sorted(domain_totals.items(), key=lambda x: x[1], reverse=True):
            print(f"  {domain:20s}: {total:,} entités")
        
        print()
        print("=" * 100)
        print("🎯 STRUCTURE CRÉÉE:")
        print("=" * 100)
        print()
        print(f"  {output_dir}/")
        print(f"  ├── administratif/")
        print(f"  │   ├── boundary_administrative.json.gz")
        print(f"  │   ├── admin_level_8.json.gz")
        print(f"  │   └── ...")
        print(f"  ├── transport/")
        print(f"  │   ├── highway_residential.json.gz")
        print(f"  │   ├── highway_service.json.gz")
        print(f"  │   └── ...")
        print(f"  ├── amenities/")
        print(f"  │   ├── amenity_restaurant.json.gz")
        print(f"  │   ├── amenity_parking.json.gz")
        print(f"  │   └── ...")
        print(f"  ├── commerce/")
        print(f"  ├── tourisme/")
        print(f"  ├── batiments/")
        print(f"  ├── nature/")
        print(f"  ├── infrastructure/")
        print(f"  ├── eau/")
        print(f"  ├── sante/")
        print(f"  ├── sport/")
        print(f"  └── autres/")
        print()
        print("💡 Chaque fichier .json.gz contient les entités au format JSON (une par ligne)")
        print("   Décompressez avec gzip pour lire le JSON")
        print()
        print("=" * 100)
        print("🎉 VOUS AVEZ MAINTENANT UN MIROIR COMPLET ET EXPLOITABLE !")
        print("=" * 100)
        
        # Sauvegarder les statistiques
        stats_file = output_dir / "extraction_stats.json"
        with open(stats_file, 'w', encoding='utf-8') as f:
            json.dump({
                "total_processed": handler.processed,
                "domain_totals": dict(domain_totals),
                "table_details": dict(handler.stats)
            }, f, ensure_ascii=False, indent=2)
        
        print(f"📊 Statistiques sauvegardées: {stats_file}")
        
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()

