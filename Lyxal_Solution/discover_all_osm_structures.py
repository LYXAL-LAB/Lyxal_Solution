#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
DÉCOUVERTE EXHAUSTIVE de TOUTES les structures OSM France.
Scanne le fichier complet pour identifier TOUS les tags et combinaisons utilisés.
Révèle le VÉRITABLE potentiel multi-domaines de la base OSM.
"""

import osmium
import json
from collections import defaultdict, Counter
from pathlib import Path

class OSMStructureDiscoverer(osmium.SimpleHandler):
    """
    Découvre TOUTES les structures de tables dans OSM en scannant tous les tags.
    """
    
    def __init__(self):
        super().__init__()
        
        # Compteurs par type d'entité
        self.node_count = 0
        self.way_count = 0
        self.relation_count = 0
        
        # Dictionnaires de tags par type
        self.node_tags = defaultdict(Counter)
        self.way_tags = defaultdict(Counter)
        self.relation_tags = defaultdict(Counter)
        
        # Combinaisons de tags (tables logiques)
        self.tag_combinations_nodes = Counter()
        self.tag_combinations_ways = Counter()
        self.tag_combinations_relations = Counter()
        
        # Tags uniques globaux
        self.all_tag_keys = set()
        
        # Échantillons de valeurs par tag
        self.tag_value_samples = defaultdict(set)
        
        # Compteur pour logging
        self.processed = 0
        
    def node(self, n):
        """Traite un node."""
        self.node_count += 1
        self.processed += 1
        
        if self.processed % 1000000 == 0:
            print(f"   Traité: {self.processed:,} entités...", end='\r')
        
        if len(n.tags) > 0:
            # Enregistrer chaque tag
            for tag in n.tags:
                self.node_tags[tag.k][tag.v] += 1
                self.all_tag_keys.add(tag.k)
                
                # Échantillon de valeurs (max 10 par tag)
                if len(self.tag_value_samples[tag.k]) < 10:
                    self.tag_value_samples[tag.k].add(tag.v)
            
            # Enregistrer la combinaison de tags (signature de table)
            tag_signature = tuple(sorted([tag.k for tag in n.tags]))
            self.tag_combinations_nodes[tag_signature] += 1
    
    def way(self, w):
        """Traite un way."""
        self.way_count += 1
        self.processed += 1
        
        if self.processed % 1000000 == 0:
            print(f"   Traité: {self.processed:,} entités...", end='\r')
        
        if len(w.tags) > 0:
            for tag in w.tags:
                self.way_tags[tag.k][tag.v] += 1
                self.all_tag_keys.add(tag.k)
                
                if len(self.tag_value_samples[tag.k]) < 10:
                    self.tag_value_samples[tag.k].add(tag.v)
            
            tag_signature = tuple(sorted([tag.k for tag in w.tags]))
            self.tag_combinations_ways[tag_signature] += 1
    
    def relation(self, r):
        """Traite une relation."""
        self.relation_count += 1
        self.processed += 1
        
        if self.processed % 1000000 == 0:
            print(f"   Traité: {self.processed:,} entités...", end='\r')
        
        if len(r.tags) > 0:
            for tag in r.tags:
                self.relation_tags[tag.k][tag.v] += 1
                self.all_tag_keys.add(tag.k)
                
                if len(self.tag_value_samples[tag.k]) < 10:
                    self.tag_value_samples[tag.k].add(tag.v)
            
            tag_signature = tuple(sorted([tag.k for tag in r.tags]))
            self.tag_combinations_relations[tag_signature] += 1


def analyze_and_report(handler):
    """Analyse les résultats et génère le rapport complet."""
    
    print()
    print()
    print("=" * 100)
    print("DÉCOUVERTE EXHAUSTIVE - TOUTES LES STRUCTURES OSM FRANCE")
    print("=" * 100)
    print()
    
    # Statistiques globales
    print("📊 STATISTIQUES GLOBALES")
    print("-" * 100)
    print(f"  Nodes analysés:     {handler.node_count:,}")
    print(f"  Ways analysés:      {handler.way_count:,}")
    print(f"  Relations analysées: {handler.relation_count:,}")
    print(f"  TOTAL:              {handler.processed:,} entités")
    print()
    print(f"  Tags uniques:       {len(handler.all_tag_keys):,} clés différentes")
    print()
    
    # TOP 50 tags les plus utilisés
    print("=" * 100)
    print("🏆 TOP 50 TAGS LES PLUS UTILISÉS (Toutes entités confondues)")
    print("=" * 100)
    print()
    
    # Combiner tous les tags
    all_tags_combined = Counter()
    for key in handler.all_tag_keys:
        count = (
            sum(handler.node_tags[key].values()) +
            sum(handler.way_tags[key].values()) +
            sum(handler.relation_tags[key].values())
        )
        all_tags_combined[key] = count
    
    for rank, (tag_key, count) in enumerate(all_tags_combined.most_common(50), 1):
        # Échantillon de valeurs
        samples = list(handler.tag_value_samples[tag_key])[:5]
        samples_str = ", ".join(f"'{s}'" for s in samples)
        if len(handler.tag_value_samples[tag_key]) > 5:
            samples_str += ", ..."
        
        print(f"  {rank:2d}. {tag_key:25s} → {count:,} occurrences")
        print(f"      Exemples: {samples_str}")
        print()
    
    # Identifier les TABLES LOGIQUES (par tag principal)
    print("=" * 100)
    print("📋 TABLES LOGIQUES IDENTIFIÉES PAR DOMAINE")
    print("=" * 100)
    print()
    
    # Catégoriser par domaine
    domains = {
        "🏛️  ADMINISTRATIF": ["boundary", "admin_level", "postal_code"],
        "🚗 TRANSPORT": ["highway", "railway", "public_transport", "route", "aeroway"],
        "📍 AMENITIES (Services)": ["amenity"],
        "🛍️  COMMERCE": ["shop"],
        "🎭 TOURISME": ["tourism", "historic"],
        "🏢 BÂTIMENTS": ["building"],
        "🌳 NATURE": ["natural", "landuse", "leisure"],
        "⚡ INFRASTRUCTURE": ["power", "man_made"],
        "💧 EAU": ["waterway", "water"],
        "🏥 SANTÉ": ["healthcare"],
        "🎓 ÉDUCATION": ["education"],
        "⚽ SPORT": ["sport"],
        "🎨 CULTURE": ["cultural", "artwork"],
    }
    
    discovered_tables = {}
    
    for domain, key_tags in domains.items():
        discovered_tables[domain] = {}
        
        for key_tag in key_tags:
            if key_tag in handler.node_tags:
                values = handler.node_tags[key_tag]
                discovered_tables[domain][key_tag] = {
                    "values": dict(values.most_common(20)),
                    "total": sum(values.values())
                }
            
            if key_tag in handler.way_tags:
                values = handler.way_tags[key_tag]
                if key_tag in discovered_tables[domain]:
                    discovered_tables[domain][key_tag]["total"] += sum(values.values())
                    for v, count in values.most_common(20):
                        discovered_tables[domain][key_tag]["values"][v] = \
                            discovered_tables[domain][key_tag]["values"].get(v, 0) + count
                else:
                    discovered_tables[domain][key_tag] = {
                        "values": dict(values.most_common(20)),
                        "total": sum(values.values())
                    }
            
            if key_tag in handler.relation_tags:
                values = handler.relation_tags[key_tag]
                if key_tag in discovered_tables[domain]:
                    discovered_tables[domain][key_tag]["total"] += sum(values.values())
                    for v, count in values.most_common(20):
                        discovered_tables[domain][key_tag]["values"][v] = \
                            discovered_tables[domain][key_tag]["values"].get(v, 0) + count
                else:
                    discovered_tables[domain][key_tag] = {
                        "values": dict(values.most_common(20)),
                        "total": sum(values.values())
                    }
    
    # Afficher par domaine
    for domain, tags_data in discovered_tables.items():
        if not tags_data:
            continue
        
        print(f"{domain}")
        print("-" * 100)
        
        for tag_key, data in sorted(tags_data.items(), key=lambda x: x[1]["total"], reverse=True):
            print(f"  Tag: {tag_key} ({data['total']:,} occurrences)")
            
            # Top valeurs
            sorted_values = sorted(data['values'].items(), key=lambda x: x[1], reverse=True)
            for value, count in sorted_values[:10]:
                table_name = f"{tag_key}_{value}".replace(":", "_")
                print(f"    → TABLE: {table_name:40s} ({count:,} entités)")
            
            if len(sorted_values) > 10:
                remaining = sum(c for v, c in sorted_values[10:])
                print(f"    → ... et {len(sorted_values) - 10} autres valeurs ({remaining:,} entités)")
            
            print()
        
        print()
    
    # Sauvegarder les résultats complets
    output_data = {
        "stats": {
            "nodes": handler.node_count,
            "ways": handler.way_count,
            "relations": handler.relation_count,
            "total": handler.processed,
            "unique_tags": len(handler.all_tag_keys)
        },
        "all_tags": {key: all_tags_combined[key] for key in handler.all_tag_keys},
        "domains": discovered_tables,
        "tag_samples": {k: list(v) for k, v in handler.tag_value_samples.items()}
    }
    
    output_file = Path("osm_france_complete_schema.json")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print("=" * 100)
    print("💾 RÉSULTATS SAUVEGARDÉS")
    print("=" * 100)
    print(f"  Fichier: {output_file}")
    print(f"  Contient: TOUS les tags, valeurs, et comptages réels")
    print()
    
    # Résumé du potentiel
    print("=" * 100)
    print("🎯 POTENTIEL MULTI-APPLICATIONS IDENTIFIÉ")
    print("=" * 100)
    print()
    
    total_tables = sum(len(tags_data) for tags_data in discovered_tables.values())
    
    print(f"  📊 {len(handler.all_tag_keys):,} types de tags différents identifiés")
    print(f"  📋 {total_tables} domaines de tables principales")
    print(f"  💾 Centaines de tables logiques extraibles")
    print()
    
    print("  Applications possibles:")
    print("    ✅ CRM - Base de partenaires/clients")
    print("    ✅ Marketing - Ciblage géographique")
    print("    ✅ Logistique - Optimisation livraisons")
    print("    ✅ Santé - Cartographie sanitaire")
    print("    ✅ Éducation - Annuaires éducatifs")
    print("    ✅ Commerce - Annuaires commerciaux")
    print("    ✅ Tourisme - Guides touristiques")
    print("    ✅ Finance - Services bancaires")
    print("    ✅ Immobilier - Analyses territoriales")
    print("    ✅ Emergency - Services d'urgence")
    print("    ✅ ... et bien plus !")
    print()
    print("=" * 100)


def main():
    osm_file = Path("osm_data/france-latest.osm.pbf")
    
    if not osm_file.exists():
        print("❌ Fichier OSM introuvable")
        return
    
    print("=" * 100)
    print("SCAN COMPLET DU FICHIER OSM FRANCE")
    print("=" * 100)
    print()
    print(f"📁 Fichier: {osm_file}")
    print(f"💾 Taille: {osm_file.stat().st_size / (1024**3):.2f} GB")
    print()
    print("⏳ Analyse en cours (peut prendre 20-40 minutes)...")
    print("   Cela va scanner TOUTES les entités pour découvrir TOUTES les structures.")
    print()
    
    # Créer le handler et lancer le scan
    handler = OSMStructureDiscoverer()
    
    try:
        handler.apply_file(str(osm_file))
        
        print()
        print("✅ Scan terminé ! Génération du rapport...")
        print()
        
        # Analyser et afficher les résultats
        analyze_and_report(handler)
        
    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()

