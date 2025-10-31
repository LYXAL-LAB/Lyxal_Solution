#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extraction des codes NAF Rev 2 depuis le fichier Excel
"""

import pandas as pd
from pathlib import Path
import json

def extract_naf_codes():
    file_path = Path("int_courts_naf_rev_2.xls")
    
    if not file_path.exists():
        print("❌ Fichier introuvable")
        return
    
    print("=" * 100)
    print("EXTRACTION DES CODES NAF REV 2")
    print("=" * 100)
    print()
    print(f"📁 Fichier: {file_path}")
    print(f"💾 Taille: {file_path.stat().st_size / 1024:.2f} KB")
    print()
    print("⏳ Lecture du fichier Excel...")
    
    # Lire le fichier Excel
    df = pd.read_excel(file_path)
    
    print()
    print("=" * 100)
    print("📊 STRUCTURE DU FICHIER")
    print("=" * 100)
    print()
    print(f"Nombre de lignes:   {len(df):,}")
    print(f"Nombre de colonnes: {len(df.columns)}")
    print()
    
    print("Colonnes disponibles:")
    print("-" * 80)
    for i, col in enumerate(df.columns, 1):
        print(f"  {i}. {col}")
    
    print()
    print("=" * 100)
    print("🔍 APERÇU DES DONNÉES (20 premières lignes)")
    print("=" * 100)
    print()
    print(df.head(20).to_string())
    
    print()
    print()
    print("=" * 100)
    print("📊 STATISTIQUES")
    print("=" * 100)
    print()
    
    # Analyser les colonnes principales
    for col in df.columns:
        non_null = df[col].notna().sum()
        pct = (non_null / len(df)) * 100
        print(f"  {col:40s}: {non_null:6,} valeurs ({pct:5.1f}%)")
    
    print()
    print()
    print("=" * 100)
    print("💾 EXPORT DES DONNÉES")
    print("=" * 100)
    print()
    
    # Exporter en JSON pour SurrealDB
    output_json = Path("naf_rev2_codes.json")
    
    # Convertir en liste de dictionnaires
    records = df.to_dict('records')
    
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(records, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Export JSON: {output_json} ({len(records):,} codes)")
    
    # Exporter aussi en JSONL (une ligne par code)
    output_jsonl = Path("naf_rev2_codes.jsonl")
    
    with open(output_jsonl, 'w', encoding='utf-8') as f:
        for record in records:
            f.write(json.dumps(record, ensure_ascii=False) + '\n')
    
    print(f"✅ Export JSONL: {output_jsonl} ({len(records):,} codes)")
    
    # Exporter en CSV aussi
    output_csv = Path("naf_rev2_codes.csv")
    df.to_csv(output_csv, index=False, encoding='utf-8-sig')
    
    print(f"✅ Export CSV: {output_csv} ({len(records):,} codes)")
    
    print()
    print()
    print("=" * 100)
    print("🎯 RÉSUMÉ")
    print("=" * 100)
    print()
    print(f"   Codes NAF Rev 2 extraits: {len(records):,}")
    print()
    print("   Fichiers générés:")
    print(f"     - {output_json} (format JSON)")
    print(f"     - {output_jsonl} (format JSONL)")
    print(f"     - {output_csv} (format CSV)")
    print()
    print("   Prêt pour import dans SurrealDB ! ✅")
    print()
    print("=" * 100)
    
    # Afficher quelques exemples
    print()
    print("📋 EXEMPLES DE CODES (10 premiers):")
    print("-" * 80)
    for i, record in enumerate(records[:10], 1):
        print(f"\n  {i}. {record}")
    print()

if __name__ == "__main__":
    extract_naf_codes()

