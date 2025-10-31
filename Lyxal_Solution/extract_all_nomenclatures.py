#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extraction COMPLÈTE de toutes les nomenclatures d'activités françaises
"""

import pandas as pd
from pathlib import Path
import json

def extract_all_nomenclatures():
    code_naf_dir = Path("Code_NAF")
    
    print("=" * 100)
    print("EXTRACTION COMPLÈTE DE TOUTES LES NOMENCLATURES D'ACTIVITÉS")
    print("=" * 100)
    print()
    
    all_nomenclatures = {}
    
    # 1. NAF REV 2 (déjà extrait, mais on vérifie)
    print("=" * 100)
    print("1️⃣  NAF REV 2 (2008 - Actuel)")
    print("=" * 100)
    print()
    
    naf_rev2_file = code_naf_dir / "int_courts_naf_rev_2.xls"
    if naf_rev2_file.exists():
        print(f"✅ Trouvé: {naf_rev2_file.name}")
        df_rev2 = pd.read_excel(naf_rev2_file)
        df_rev2.columns = ['ligne', 'code', 'libelle_long', 'libelle_65', 'libelle_40']
        df_rev2 = df_rev2[df_rev2['code'].notna()].copy()
        df_rev2['nomenclature'] = 'NAFRev2'
        all_nomenclatures['NAFRev2'] = df_rev2
        print(f"   Codes extraits: {len(df_rev2):,}")
    print()
    
    # 2. NAF 2003 (NAF Rev 1)
    print("=" * 100)
    print("2️⃣  NAF 2003 / NAF REV 1 (2003-2008)")
    print("=" * 100)
    print()
    
    naf2003_file = code_naf_dir / "naf2003_n1-5.xls"
    if naf2003_file.exists():
        print(f"✅ Trouvé: {naf2003_file.name}")
        try:
            df_2003 = pd.read_excel(naf2003_file)
            print(f"   Colonnes: {list(df_2003.columns)}")
            print(f"   Lignes: {len(df_2003):,}")
            print()
            print("   Aperçu:")
            print(df_2003.head(10).to_string())
            
            # Adapter selon la structure réelle
            if len(df_2003.columns) >= 2:
                df_2003['nomenclature'] = 'NAFRev1'
                all_nomenclatures['NAFRev1'] = df_2003
                print(f"\n   ✅ Codes extraits: {len(df_2003):,}")
        except Exception as e:
            print(f"   ⚠️  Erreur lors de la lecture: {e}")
    print()
    
    # 3. NAF 1993
    print("=" * 100)
    print("3️⃣  NAF 1993 (1993-2003)")
    print("=" * 100)
    print()
    
    naf1993_file = code_naf_dir / "naf1993_5_niveaux.xls"
    if naf1993_file.exists():
        print(f"✅ Trouvé: {naf1993_file.name}")
        try:
            df_1993 = pd.read_excel(naf1993_file)
            print(f"   Colonnes: {list(df_1993.columns)}")
            print(f"   Lignes: {len(df_1993):,}")
            print()
            print("   Aperçu:")
            print(df_1993.head(10).to_string())
            
            if len(df_1993.columns) >= 2:
                df_1993['nomenclature'] = 'NAF1993'
                all_nomenclatures['NAF1993'] = df_1993
                print(f"\n   ✅ Codes extraits: {len(df_1993):,}")
        except Exception as e:
            print(f"   ⚠️  Erreur lors de la lecture: {e}")
    print()
    
    # 4. NAP (1973-1993)
    print("=" * 100)
    print("4️⃣  NAP (1973-1993)")
    print("=" * 100)
    print()
    
    nap_file = code_naf_dir / "NAP 1973_1993.xls"
    if nap_file.exists():
        print(f"✅ Trouvé: {nap_file.name}")
        try:
            df_nap = pd.read_excel(nap_file)
            print(f"   Colonnes: {list(df_nap.columns)}")
            print(f"   Lignes: {len(df_nap):,}")
            print()
            print("   Aperçu:")
            print(df_nap.head(10).to_string())
            
            if len(df_nap.columns) >= 2:
                df_nap['nomenclature'] = 'NAP'
                all_nomenclatures['NAP'] = df_nap
                print(f"\n   ✅ Codes extraits: {len(df_nap):,}")
        except Exception as e:
            print(f"   ⚠️  Erreur lors de la lecture: {e}")
    print()
    
    # Résumé
    print()
    print("=" * 100)
    print("📊 RÉSUMÉ DE L'EXTRACTION")
    print("=" * 100)
    print()
    
    total_codes = 0
    for nomenclature, df in all_nomenclatures.items():
        count = len(df)
        total_codes += count
        print(f"   {nomenclature:15s}: {count:6,} codes")
    
    print()
    print(f"   TOTAL:            {total_codes:6,} codes")
    print()
    print("=" * 100)
    
    # Sauvegarder les statistiques
    stats = {
        "nomenclatures": {
            name: {
                "count": len(df),
                "columns": list(df.columns)
            }
            for name, df in all_nomenclatures.items()
        },
        "total": total_codes
    }
    
    with open("nomenclatures_stats.json", 'w', encoding='utf-8') as f:
        json.dump(stats, f, ensure_ascii=False, indent=2)
    
    print()
    print("✅ Statistiques sauvegardées: nomenclatures_stats.json")
    print()

if __name__ == "__main__":
    extract_all_nomenclatures()

