#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyse de la structure du fichier JSONL SIRENE
"""

import json
from pathlib import Path
from collections import defaultdict

def analyze_jsonl_structure():
    file_path = Path("Lyxal_Solution/jeux de données/StockUniteLegale_utf8.jsonl")
    
    if not file_path.exists():
        print("❌ Fichier introuvable")
        return
    
    print("=" * 100)
    print("ANALYSE DE LA STRUCTURE DU FICHIER JSONL SIRENE")
    print("=" * 100)
    print()
    print(f"📁 Fichier: {file_path}")
    print(f"💾 Taille: {file_path.stat().st_size / (1024**2):.2f} MB")
    print()
    
    # Lire quelques lignes pour analyser la structure
    all_keys = set()
    sample_records = []
    total_lines = 0
    
    print("⏳ Lecture et analyse du fichier...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            total_lines += 1
            if line.strip():
                try:
                    record = json.loads(line)
                    all_keys.update(record.keys())
                    if i < 5:  # Garder 5 exemples
                        sample_records.append(record)
                except json.JSONDecodeError:
                    print(f"⚠️  Erreur de décodage à la ligne {i+1}")
            
            # Progress
            if (i + 1) % 100000 == 0:
                print(f"   ... {i+1:,} lignes analysées")
    
    print()
    print("=" * 100)
    print("📊 STRUCTURE GLOBALE")
    print("=" * 100)
    print()
    print(f"Nombre total d'enregistrements: {total_lines:,}")
    print(f"Nombre de champs uniques:       {len(all_keys)}")
    print()
    
    print("=" * 100)
    print("🗂️  NOMBRE DE TABLES")
    print("=" * 100)
    print()
    print("Ce fichier contient UNE SEULE TABLE: 'UniteLegale' (entreprises)")
    print()
    print("Il s'agit d'un fichier PLAT avec tous les enregistrements au même niveau.")
    print()
    
    print("=" * 100)
    print("📋 LISTE COMPLÈTE DES CHAMPS (Fields)")
    print("=" * 100)
    print()
    
    # Trier les champs par catégorie
    sorted_keys = sorted(all_keys)
    
    for i, key in enumerate(sorted_keys, 1):
        print(f"  {i:2d}. {key}")
    
    print()
    print("=" * 100)
    print("🔍 EXEMPLES D'ENREGISTREMENTS")
    print("=" * 100)
    print()
    
    for i, record in enumerate(sample_records[:3], 1):
        print(f"\nEnregistrement #{i}:")
        print("-" * 80)
        for key, value in record.items():
            value_str = str(value)
            if len(value_str) > 60:
                value_str = value_str[:57] + "..."
            print(f"  {key:45s}: {value_str}")
    
    print()
    print()
    print("=" * 100)
    print("📂 CATÉGORISATION DES CHAMPS")
    print("=" * 100)
    print()
    
    # Catégoriser les champs
    categories = {
        "Identification": [],
        "Dénomination": [],
        "Géographie": [],
        "Activité économique": [],
        "Juridique": [],
        "Effectifs": [],
        "Administratif": [],
        "Dates": [],
        "Autres": []
    }
    
    for key in sorted_keys:
        key_lower = key.lower()
        if any(x in key_lower for x in ['siren', 'nic', 'siret']):
            categories["Identification"].append(key)
        elif any(x in key_lower for x in ['denomination', 'nom', 'sigle', 'enseigne']):
            categories["Dénomination"].append(key)
        elif any(x in key_lower for x in ['commune', 'postal', 'adresse', 'pays', 'geo', 'region', 'departement']):
            categories["Géographie"].append(key)
        elif any(x in key_lower for x in ['activite', 'ape', 'naf', 'nomenclature']):
            categories["Activité économique"].append(key)
        elif any(x in key_lower for x in ['juridique', 'forme', 'categorie']):
            categories["Juridique"].append(key)
        elif any(x in key_lower for x in ['effectif', 'salarie']):
            categories["Effectifs"].append(key)
        elif any(x in key_lower for x in ['etat', 'administratif', 'economiesociale']):
            categories["Administratif"].append(key)
        elif any(x in key_lower for x in ['date', 'annee', 'periode']):
            categories["Dates"].append(key)
        else:
            categories["Autres"].append(key)
    
    for category, fields in categories.items():
        if fields:
            print(f"\n{category}:")
            print("-" * 80)
            for field in fields:
                print(f"  • {field}")
    
    print()
    print()
    print("=" * 100)
    print("🎯 RÉPONSE À VOTRE QUESTION")
    print("=" * 100)
    print()
    print("❓ Nombre de tables: 1 TABLE UNIQUE")
    print()
    print("   → Table: 'UniteLegale' (Stock des entreprises françaises)")
    print()
    print(f"❓ Nombre de champs: {len(all_keys)} FIELDS")
    print()
    print("   Structure:")
    print("   - Fichier PLAT (pas de relations imbriquées)")
    print("   - Un enregistrement JSON par ligne")
    print("   - Tous les champs au même niveau")
    print()
    print("💡 Pour SurrealDB:")
    print()
    print("   Vous pouvez créer:")
    print("   - 1 table principale: 'sirene_unite_legale'")
    print("   - Relations possibles:")
    print("     → vers base_city (via codeCommuneEtablissement)")
    print("     → vers base_country (via codePaysEtrangerEtablissement)")
    print("     → tables de référence (activités, formes juridiques)")
    print()
    print("=" * 100)
    
    # Sauvegarder l'analyse
    analysis = {
        "nombre_enregistrements": total_lines,
        "nombre_tables": 1,
        "tables": {
            "unite_legale": {
                "nombre_champs": len(all_keys),
                "champs": sorted_keys,
                "categories": {k: v for k, v in categories.items() if v}
            }
        }
    }
    
    output_file = Path("sirene_structure_analysis.json")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, ensure_ascii=False, indent=2)
    
    print(f"📄 Analyse sauvegardée: {output_file}")
    print()

if __name__ == "__main__":
    analyze_jsonl_structure()

