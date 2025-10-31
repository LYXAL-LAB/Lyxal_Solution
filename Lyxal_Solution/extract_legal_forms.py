#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extrait et structure les catégories juridiques officielles
"""

import pandas as pd
from pathlib import Path
import json

def extract_legal_forms():
    file_path = Path("cj_septembre_2022.xls")
    
    print("=" * 100)
    print("EXTRACTION DES CATÉGORIES JURIDIQUES OFFICIELLES")
    print("=" * 100)
    print()
    print(f"📁 Lecture: {file_path}")
    
    # Lire tout le fichier
    df = pd.read_excel(file_path)
    
    print(f"✅ {len(df)} lignes chargées")
    print()
    print("📋 Aperçu du fichier:")
    print("-" * 100)
    for i, row in df.iterrows():
        col1 = str(row.iloc[0]) if pd.notna(row.iloc[0]) else 'NaN'
        col2 = str(row.iloc[1]) if pd.notna(row.iloc[1]) else 'NaN'
        print(f"  {i:3d}: '{col1[:50]:50s}' | '{col2[:50]:50s}'")
    
    print()
    print("=" * 100)
    
    # Le fichier semble avoir plusieurs sections
    # Essayons de lire en sautant les premières lignes
    print()
    print("Lecture avec différentes stratégies...")
    print()
    
    # Stratégie 1: Lire tous les sheets
    xl_file = pd.ExcelFile(file_path)
    print(f"Nombre de sheets: {len(xl_file.sheet_names)}")
    print(f"Noms des sheets: {xl_file.sheet_names}")
    print()
    
    for sheet_name in xl_file.sheet_names:
        print(f"\n{'='*100}")
        print(f"Sheet: {sheet_name}")
        print('='*100)
        
        df_sheet = pd.read_excel(file_path, sheet_name=sheet_name, header=None)
        print(f"Lignes: {len(df_sheet)}, Colonnes: {len(df_sheet.columns)}")
        print()
        print("Aperçu:")
        print(df_sheet.head(30).to_string())

if __name__ == "__main__":
    extract_legal_forms()

