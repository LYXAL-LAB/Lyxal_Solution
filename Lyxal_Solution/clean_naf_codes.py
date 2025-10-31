#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Nettoyage et structuration des codes NAF Rev 2 pour SurrealDB
"""

import pandas as pd
from pathlib import Path
import json
import re

def clean_naf_codes():
    file_path = Path("int_courts_naf_rev_2.xls")
    
    print("=" * 100)
    print("NETTOYAGE ET STRUCTURATION DES CODES NAF REV 2")
    print("=" * 100)
    print()
    print("⏳ Lecture et nettoyage des données...")
    
    # Lire le fichier Excel
    df = pd.read_excel(file_path)
    
    # Nettoyer les noms de colonnes
    df.columns = [
        'ligne',
        'code',
        'libelle_long',
        'libelle_65',
        'libelle_40'
    ]
    
    # Supprimer les lignes vides (où code est NaN)
    df_clean = df[df['code'].notna()].copy()
    
    # Nettoyer les espaces dans le code
    df_clean['code'] = df_clean['code'].astype(str).str.strip()
    
    # Déterminer le niveau hiérarchique
    def get_level(code):
        if code.startswith('SECTION'):
            return 'section'
        elif re.match(r'^\d{2}$', code):
            return 'division'
        elif re.match(r'^\d{2}\.\d$', code):
            return 'groupe'
        elif re.match(r'^\d{2}\.\d{2}$', code):
            return 'classe'
        elif re.match(r'^\d{2}\.\d{2}[A-Z]$', code):
            return 'sous_classe'
        else:
            return 'autre'
    
    df_clean['niveau'] = df_clean['code'].apply(get_level)
    
    # Extraire la section pour les autres niveaux
    def get_section(code):
        if code.startswith('SECTION'):
            return code
        return None
    
    # Nettoyer les libellés (enlever les espaces superflus)
    for col in ['libelle_long', 'libelle_65', 'libelle_40']:
        df_clean[col] = df_clean[col].str.strip()
    
    print()
    print("=" * 100)
    print("📊 RÉSULTATS DU NETTOYAGE")
    print("=" * 100)
    print()
    print(f"Lignes d'origine:     {len(df):,}")
    print(f"Lignes nettoyées:     {len(df_clean):,}")
    print(f"Lignes supprimées:    {len(df) - len(df_clean):,}")
    print()
    
    # Statistiques par niveau
    print("Répartition par niveau:")
    print("-" * 80)
    for niveau, count in df_clean['niveau'].value_counts().sort_index().items():
        print(f"  {niveau:15s}: {count:4,} codes")
    
    print()
    print()
    print("=" * 100)
    print("📋 EXEMPLES PAR NIVEAU")
    print("=" * 100)
    
    for niveau in ['section', 'division', 'groupe', 'classe', 'sous_classe']:
        examples = df_clean[df_clean['niveau'] == niveau].head(3)
        if not examples.empty:
            print()
            print(f"\n{niveau.upper()}:")
            print("-" * 80)
            for _, row in examples.iterrows():
                print(f"  {row['code']:15s}: {row['libelle_long']}")
    
    print()
    print()
    print("=" * 100)
    print("💾 EXPORT DES DONNÉES NETTOYÉES")
    print("=" * 100)
    print()
    
    # Exporter en JSON
    output_json = Path("naf_rev2_clean.json")
    records = df_clean.to_dict('records')
    
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(records, f, ensure_ascii=False, indent=2)
    
    print(f"✅ {output_json} ({len(records):,} codes)")
    
    # Exporter en JSONL
    output_jsonl = Path("naf_rev2_clean.jsonl")
    
    with open(output_jsonl, 'w', encoding='utf-8') as f:
        for record in records:
            f.write(json.dumps(record, ensure_ascii=False) + '\n')
    
    print(f"✅ {output_jsonl} ({len(records):,} codes)")
    
    # Exporter uniquement les sous-classes (codes terminaux avec Z)
    df_terminal = df_clean[df_clean['niveau'] == 'sous_classe'].copy()
    
    output_terminal = Path("naf_rev2_terminal.json")
    terminal_records = df_terminal.to_dict('records')
    
    with open(output_terminal, 'w', encoding='utf-8') as f:
        json.dump(terminal_records, f, ensure_ascii=False, indent=2)
    
    print(f"✅ {output_terminal} ({len(terminal_records):,} codes terminaux)")
    
    # Exporter en CSV
    output_csv = Path("naf_rev2_clean.csv")
    df_clean.to_csv(output_csv, index=False, encoding='utf-8-sig')
    
    print(f"✅ {output_csv} ({len(records):,} codes)")
    
    print()
    print()
    print("=" * 100)
    print("🎯 STATISTIQUES FINALES")
    print("=" * 100)
    print()
    print(f"   Total des codes:           {len(df_clean):,}")
    print(f"   Codes terminaux (Z):       {len(df_terminal):,}")
    print()
    print("   Niveaux hiérarchiques:")
    for niveau, count in df_clean['niveau'].value_counts().sort_index().items():
        print(f"     - {niveau:15s}: {count:4,} codes")
    print()
    print("=" * 100)
    
    # Top 20 des codes terminaux les plus utilisés (à croiser avec SIRENE)
    print()
    print("📋 QUELQUES EXEMPLES DE CODES TERMINAUX:")
    print("-" * 80)
    for i, row in df_terminal.head(20).iterrows():
        print(f"  {row['code']:10s}: {row['libelle_40']}")
    
    print()
    print()
    print("=" * 100)
    print("✅ PRÊT POUR SURREALDB")
    print("=" * 100)
    print()
    print("Fichiers disponibles:")
    print()
    print(f"  1. {output_json}")
    print("     → Tous les codes (sections, divisions, groupes, classes, sous-classes)")
    print()
    print(f"  2. {output_terminal}")
    print("     → Uniquement les codes terminaux (sous-classes avec Z)")
    print("     → Utilisés dans le fichier SIRENE")
    print()
    print(f"  3. {output_jsonl}")
    print("     → Format JSONL (une ligne par code)")
    print()
    print(f"  4. {output_csv}")
    print("     → Format CSV")
    print()
    print("=" * 100)

if __name__ == "__main__":
    clean_naf_codes()

