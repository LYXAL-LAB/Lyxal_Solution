#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extrait la hiérarchie complète des catégories juridiques
"""

import pandas as pd
from pathlib import Path
import json

def extract_complete_legal_forms():
    file_path = Path("cj_septembre_2022.xls")
    
    print("=" * 100)
    print("EXTRACTION COMPLÈTE DES CATÉGORIES JURIDIQUES")
    print("=" * 100)
    print()
    
    xl_file = pd.ExcelFile(file_path)
    
    all_legal_forms = []
    
    # Niveau I - Grandes catégories
    print("1️⃣  Extraction Niveau I...")
    df_n1 = pd.read_excel(file_path, sheet_name='Niveau I', header=None, skiprows=4)
    
    for _, row in df_n1.iterrows():
        if pd.notna(row[0]) and pd.notna(row[1]):
            code = str(row[0]).strip()
            libelle = str(row[1]).strip()
            
            if code.isdigit():
                all_legal_forms.append({
                    'code': code,
                    'niveau': 1,
                    'libelle': libelle,
                    'parent_code': None
                })
    
    print(f"   ✅ {len([f for f in all_legal_forms if f['niveau'] == 1])} catégories Niveau I")
    
    # Niveau II - Catégories moyennes
    print("2️⃣  Extraction Niveau II...")
    df_n2 = pd.read_excel(file_path, sheet_name='Niveau II', header=None, skiprows=4)
    
    for _, row in df_n2.iterrows():
        if pd.notna(row[0]) and pd.notna(row[1]):
            code = str(row[0]).strip()
            libelle = str(row[1]).strip()
            
            if code.isdigit() and len(code) == 2:
                parent = code[0]  # Premier chiffre = parent Niveau I
                all_legal_forms.append({
                    'code': code,
                    'niveau': 2,
                    'libelle': libelle,
                    'parent_code': parent
                })
    
    print(f"   ✅ {len([f for f in all_legal_forms if f['niveau'] == 2])} catégories Niveau II")
    
    # Niveau III - Catégories détaillées (utilisées dans SIRENE)
    print("3️⃣  Extraction Niveau III...")
    df_n3 = pd.read_excel(file_path, sheet_name='Niveau III', header=None, skiprows=4)
    
    for _, row in df_n3.iterrows():
        if pd.notna(row[0]) and pd.notna(row[1]):
            code = str(row[0]).strip()
            libelle = str(row[1]).strip()
            
            if code.isdigit() and len(code) == 4:
                parent = code[:2]  # Deux premiers chiffres = parent Niveau II
                all_legal_forms.append({
                    'code': code,
                    'niveau': 3,
                    'libelle': libelle,
                    'parent_code': parent
                })
    
    print(f"   ✅ {len([f for f in all_legal_forms if f['niveau'] == 3])} catégories Niveau III")
    print()
    
    # Sauvegarder
    output_file = Path("legal_forms_complete.json")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_legal_forms, f, ensure_ascii=False, indent=2)
    
    print("=" * 100)
    print("📊 RÉSUMÉ")
    print("=" * 100)
    print()
    print(f"Total catégories: {len(all_legal_forms)}")
    print()
    
    by_level = {}
    for form in all_legal_forms:
        level = form['niveau']
        by_level[level] = by_level.get(level, 0) + 1
    
    for level in sorted(by_level.keys()):
        print(f"   Niveau {level}: {by_level[level]} catégories")
    
    print()
    print(f"📁 Fichier généré: {output_file}")
    print()
    
    # Exemples
    print("=" * 100)
    print("📋 EXEMPLES PAR NIVEAU")
    print("=" * 100)
    
    for level in [1, 2, 3]:
        print(f"\nNiveau {level}:")
        print("-" * 80)
        examples = [f for f in all_legal_forms if f['niveau'] == level][:5]
        for ex in examples:
            parent_info = f" (parent: {ex['parent_code']})" if ex['parent_code'] else ""
            print(f"   {ex['code']:6s}: {ex['libelle']}{parent_info}")
    
    print()
    print("=" * 100)

if __name__ == "__main__":
    extract_complete_legal_forms()

