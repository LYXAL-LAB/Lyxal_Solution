#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extraction COMPLÈTE et HIÉRARCHIQUE de toutes les nomenclatures
Avec TOUS les niveaux (sections, divisions, groupes, classes, sous-classes)
"""

import pandas as pd
from pathlib import Path
import json
import re

def get_level_nafrev2(code):
    """Détermine le niveau hiérarchique NAF Rev 2"""
    code = str(code).strip()
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
    return None

def get_parent_code(code, level):
    """Récupère le code parent dans la hiérarchie"""
    code = str(code).strip()
    
    if level == 'sous_classe':  # 01.11Z -> 01.11
        return code[:-1]
    elif level == 'classe':  # 01.11 -> 01.1
        return code[:4]
    elif level == 'groupe':  # 01.1 -> 01
        return code[:2]
    elif level == 'division':  # 01 -> SECTION A (à déterminer)
        return None
    
    return None

def extract_complete_hierarchical():
    code_naf_dir = Path("Code_NAF")
    output_dir = Path("nomenclatures_hierarchical")
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 100)
    print("EXTRACTION HIÉRARCHIQUE COMPLÈTE DES NOMENCLATURES")
    print("=" * 100)
    print()
    
    all_codes = []
    
    # ======================================
    # 1. NAF REV 2 - HIÉRARCHIE COMPLÈTE
    # ======================================
    print("1️⃣  NAF REV 2 (2008 - Actuel) - HIÉRARCHIE COMPLÈTE")
    print("-" * 80)
    
    naf_rev2_file = code_naf_dir / "int_courts_naf_rev_2.xls"
    df_rev2 = pd.read_excel(naf_rev2_file)
    df_rev2.columns = ['ligne', 'code', 'libelle_long', 'libelle_65', 'libelle_40']
    df_rev2 = df_rev2[df_rev2['code'].notna()].copy()
    df_rev2['code'] = df_rev2['code'].astype(str).str.strip()
    
    # Déterminer le niveau pour chaque code
    df_rev2['niveau'] = df_rev2['code'].apply(get_level_nafrev2)
    df_rev2 = df_rev2[df_rev2['niveau'].notna()].copy()
    
    # Déterminer le parent
    df_rev2['parent_code'] = df_rev2.apply(
        lambda row: get_parent_code(row['code'], row['niveau']), axis=1
    )
    
    # Statistiques par niveau
    niveau_counts = df_rev2['niveau'].value_counts()
    print()
    print("   Niveaux hiérarchiques:")
    for niveau in ['section', 'division', 'groupe', 'classe', 'sous_classe']:
        count = niveau_counts.get(niveau, 0)
        print(f"      {niveau:15s}: {count:4,} codes")
    
    # Exporter
    for _, row in df_rev2.iterrows():
        all_codes.append({
            'code': row['code'],
            'nomenclature': 'NAFRev2',
            'niveau': row['niveau'],
            'parent_code': row['parent_code'] if pd.notna(row['parent_code']) else None,
            'libelle_long': row['libelle_long'],
            'libelle_court': row['libelle_40'],
            'libelle_moyen': row['libelle_65'],
            'periode': '2008-Actuel'
        })
    
    print(f"\n   ✅ Total: {len(df_rev2):,} codes (tous niveaux)")
    print()
    
    # ======================================
    # 2. NAF 2003 / NAF REV 1
    # ======================================
    print("2️⃣  NAF 2003 / NAF REV 1 (2003-2008)")
    print("-" * 80)
    
    # Lire les 5 niveaux hiérarchiques
    naf2003_file = code_naf_dir / "naf2003_n1-5.xls"
    df_2003 = pd.read_excel(naf2003_file, skiprows=1)
    
    # Colonnes: N_700 (niveau 5), N_220 (niveau 4), N_60 (niveau 3), N_31 (niveau 2), N_17 (niveau 1)
    df_2003.columns = ['n5', 'n4', 'n3', 'n2', 'n1']
    
    # Lire les libellés pour chaque niveau
    libelles_2003 = {}
    niveau_names = {1: 'section', 2: 'division', 3: 'groupe', 4: 'classe', 5: 'sous_classe'}
    
    for i in range(1, 6):
        try:
            libelle_file = code_naf_dir / f"naf2003_liste_n{i}.xls"
            if libelle_file.exists():
                df_lib = pd.read_excel(libelle_file)
                if len(df_lib.columns) >= 2:
                    for _, row in df_lib.iterrows():
                        code = str(row.iloc[0]).strip()
                        libelle = str(row.iloc[1]).strip() if pd.notna(row.iloc[1]) else ""
                        if code and libelle and code not in ['nan', 'NaN']:
                            libelles_2003[code] = libelle
        except Exception as e:
            print(f"   ⚠️  Erreur niveau {i}: {e}")
    
    # Extraire tous les niveaux
    seen_codes_2003 = set()
    
    for _, row in df_2003.iterrows():
        # Niveau 5 (sous-classe)
        if pd.notna(row['n5']) and str(row['n5']).strip():
            code5 = str(row['n5']).strip()
            if code5 not in seen_codes_2003 and code5 not in ['nan', 'NaN', 'N_700']:
                all_codes.append({
                    'code': code5,
                    'nomenclature': 'NAFRev1',
                    'niveau': 'sous_classe',
                    'parent_code': str(row['n4']).strip() if pd.notna(row['n4']) else None,
                    'libelle_long': libelles_2003.get(code5, ''),
                    'libelle_court': libelles_2003.get(code5, ''),
                    'libelle_moyen': libelles_2003.get(code5, ''),
                    'periode': '2003-2008'
                })
                seen_codes_2003.add(code5)
        
        # Niveau 4 (classe)
        if pd.notna(row['n4']) and str(row['n4']).strip():
            code4 = str(row['n4']).strip()
            if code4 not in seen_codes_2003 and code4 not in ['nan', 'NaN', 'N_220']:
                all_codes.append({
                    'code': code4,
                    'nomenclature': 'NAFRev1',
                    'niveau': 'classe',
                    'parent_code': str(row['n3']).strip() if pd.notna(row['n3']) else None,
                    'libelle_long': libelles_2003.get(code4, ''),
                    'libelle_court': libelles_2003.get(code4, ''),
                    'libelle_moyen': libelles_2003.get(code4, ''),
                    'periode': '2003-2008'
                })
                seen_codes_2003.add(code4)
        
        # Niveau 3 (groupe)
        if pd.notna(row['n3']) and str(row['n3']).strip():
            code3 = str(row['n3']).strip()
            if code3 not in seen_codes_2003 and code3 not in ['nan', 'NaN', 'N_60']:
                all_codes.append({
                    'code': code3,
                    'nomenclature': 'NAFRev1',
                    'niveau': 'groupe',
                    'parent_code': str(row['n2']).strip() if pd.notna(row['n2']) else None,
                    'libelle_long': libelles_2003.get(code3, ''),
                    'libelle_court': libelles_2003.get(code3, ''),
                    'libelle_moyen': libelles_2003.get(code3, ''),
                    'periode': '2003-2008'
                })
                seen_codes_2003.add(code3)
        
        # Niveau 2 (division)
        if pd.notna(row['n2']) and str(row['n2']).strip():
            code2 = str(row['n2']).strip()
            if code2 not in seen_codes_2003 and code2 not in ['nan', 'NaN', 'N_31']:
                all_codes.append({
                    'code': code2,
                    'nomenclature': 'NAFRev1',
                    'niveau': 'division',
                    'parent_code': str(row['n1']).strip() if pd.notna(row['n1']) else None,
                    'libelle_long': libelles_2003.get(code2, ''),
                    'libelle_court': libelles_2003.get(code2, ''),
                    'libelle_moyen': libelles_2003.get(code2, ''),
                    'periode': '2003-2008'
                })
                seen_codes_2003.add(code2)
        
        # Niveau 1 (section)
        if pd.notna(row['n1']) and str(row['n1']).strip():
            code1 = str(row['n1']).strip()
            if code1 not in seen_codes_2003 and code1 not in ['nan', 'NaN', 'N_17']:
                all_codes.append({
                    'code': code1,
                    'nomenclature': 'NAFRev1',
                    'niveau': 'section',
                    'parent_code': None,
                    'libelle_long': libelles_2003.get(code1, ''),
                    'libelle_court': libelles_2003.get(code1, ''),
                    'libelle_moyen': libelles_2003.get(code1, ''),
                    'periode': '2003-2008'
                })
                seen_codes_2003.add(code1)
    
    print(f"   ✅ {len(seen_codes_2003):,} codes (tous niveaux)")
    print()
    
    # ======================================
    # 3. NAF 1993
    # ======================================
    print("3️⃣  NAF 1993 (1993-2003)")
    print("-" * 80)
    
    naf1993_file = code_naf_dir / "naf1993_5_niveaux.xls"
    df_1993 = pd.read_excel(naf1993_file, skiprows=1)
    df_1993.columns = ['n5', 'n4', 'n3', 'n2', 'n1']
    
    # Lire les libellés
    libelles_1993 = {}
    for i in range(1, 6):
        try:
            libelle_file = code_naf_dir / f"naf1993_liste_n{i}.xls"
            if libelle_file.exists():
                df_lib = pd.read_excel(libelle_file)
                if len(df_lib.columns) >= 2:
                    for _, row in df_lib.iterrows():
                        code = str(row.iloc[0]).strip()
                        libelle = str(row.iloc[1]).strip() if pd.notna(row.iloc[1]) else ""
                        if code and libelle and code not in ['nan', 'NaN']:
                            libelles_1993[code] = libelle
        except Exception as e:
            print(f"   ⚠️  Erreur niveau {i}: {e}")
    
    # Extraire tous les niveaux
    seen_codes_1993 = set()
    
    for _, row in df_1993.iterrows():
        for level, col, parent_col in [
            ('sous_classe', 'n5', 'n4'),
            ('classe', 'n4', 'n3'),
            ('groupe', 'n3', 'n2'),
            ('division', 'n2', 'n1'),
            ('section', 'n1', None)
        ]:
            if pd.notna(row[col]) and str(row[col]).strip():
                code = str(row[col]).strip()
                if code not in seen_codes_1993 and code not in ['nan', 'NaN', 'N_700', 'N_220', 'N_60', 'N_31', 'N_17']:
                    parent = str(row[parent_col]).strip() if parent_col and pd.notna(row[parent_col]) else None
                    all_codes.append({
                        'code': code,
                        'nomenclature': 'NAF1993',
                        'niveau': level,
                        'parent_code': parent,
                        'libelle_long': libelles_1993.get(code, ''),
                        'libelle_court': libelles_1993.get(code, ''),
                        'libelle_moyen': libelles_1993.get(code, ''),
                        'periode': '1993-2003'
                    })
                    seen_codes_1993.add(code)
    
    print(f"   ✅ {len(seen_codes_1993):,} codes (tous niveaux)")
    print()
    
    # ======================================
    # 4. NAP
    # ======================================
    print("4️⃣  NAP (1973-1993)")
    print("-" * 80)
    
    nap_file = code_naf_dir / "NAP 1973_1993.xls"
    df_nap = pd.read_excel(nap_file)
    
    # NAP a 4 niveaux: NAP15, NAP40, NAP100, NAP600
    seen_codes_nap = set()
    
    for _, row in df_nap.iterrows():
        # Niveau 4 (NAP600) - le plus détaillé
        if pd.notna(row['NAP600']):
            code = str(row['NAP600']).strip()
            if code and code not in seen_codes_nap:
                all_codes.append({
                    'code': code,
                    'nomenclature': 'NAP',
                    'niveau': 'sous_classe',
                    'parent_code': str(row['NAP100']).strip() if pd.notna(row['NAP100']) else None,
                    'libelle_long': str(row['LIB_NAP600']) if pd.notna(row['LIB_NAP600']) else '',
                    'libelle_court': str(row['LIB_NAP600'])[:40] if pd.notna(row['LIB_NAP600']) else '',
                    'libelle_moyen': str(row['LIB_NAP600'])[:65] if pd.notna(row['LIB_NAP600']) else '',
                    'periode': '1973-1993'
                })
                seen_codes_nap.add(code)
        
        # Niveau 3 (NAP100)
        if pd.notna(row['NAP100']):
            code = str(int(row['NAP100'])) if isinstance(row['NAP100'], (int, float)) else str(row['NAP100']).strip()
            if code and code not in seen_codes_nap:
                all_codes.append({
                    'code': code,
                    'nomenclature': 'NAP',
                    'niveau': 'classe',
                    'parent_code': str(row['NAP40']) if pd.notna(row['NAP40']) else None,
                    'libelle_long': str(row['LIB_NAP100']) if pd.notna(row['LIB_NAP100']) else '',
                    'libelle_court': str(row['LIB_NAP100'])[:40] if pd.notna(row['LIB_NAP100']) else '',
                    'libelle_moyen': str(row['LIB_NAP100'])[:65] if pd.notna(row['LIB_NAP100']) else '',
                    'periode': '1973-1993'
                })
                seen_codes_nap.add(code)
        
        # Niveau 2 (NAP40)
        if pd.notna(row['NAP40']):
            code = str(row['NAP40']).strip()
            if code and code not in seen_codes_nap:
                all_codes.append({
                    'code': code,
                    'nomenclature': 'NAP',
                    'niveau': 'groupe',
                    'parent_code': str(row['NAP15']) if pd.notna(row['NAP15']) else None,
                    'libelle_long': str(row['LIB_NAP40']) if pd.notna(row['LIB_NAP40']) else '',
                    'libelle_court': str(row['LIB_NAP40'])[:40] if pd.notna(row['LIB_NAP40']) else '',
                    'libelle_moyen': str(row['LIB_NAP40'])[:65] if pd.notna(row['LIB_NAP40']) else '',
                    'periode': '1973-1993'
                })
                seen_codes_nap.add(code)
        
        # Niveau 1 (NAP15)
        if pd.notna(row['NAP15']):
            code = str(row['NAP15']).strip()
            if code and code not in seen_codes_nap:
                all_codes.append({
                    'code': code,
                    'nomenclature': 'NAP',
                    'niveau': 'division',
                    'parent_code': None,
                    'libelle_long': str(row['LIB_NAP15']) if pd.notna(row['LIB_NAP15']) else '',
                    'libelle_court': str(row['LIB_NAP15'])[:40] if pd.notna(row['LIB_NAP15']) else '',
                    'libelle_moyen': str(row['LIB_NAP15'])[:65] if pd.notna(row['LIB_NAP15']) else '',
                    'periode': '1973-1993'
                })
                seen_codes_nap.add(code)
    
    print(f"   ✅ {len(seen_codes_nap):,} codes (tous niveaux)")
    print()
    
    # ======================================
    # EXPORT
    # ======================================
    print("=" * 100)
    print("💾 EXPORT DES DONNÉES HIÉRARCHIQUES")
    print("=" * 100)
    print()
    
    # 1. Export JSON complet
    output_json = output_dir / "nomenclatures_hierarchical_complete.json"
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(all_codes, f, ensure_ascii=False, indent=2)
    print(f"✅ {output_json} ({len(all_codes):,} codes)")
    
    # 2. Export JSONL
    output_jsonl = output_dir / "nomenclatures_hierarchical_complete.jsonl"
    with open(output_jsonl, 'w', encoding='utf-8') as f:
        for code in all_codes:
            f.write(json.dumps(code, ensure_ascii=False) + '\n')
    print(f"✅ {output_jsonl} ({len(all_codes):,} codes)")
    
    # 3. Export par nomenclature
    from collections import defaultdict
    by_nomenclature = defaultdict(list)
    
    for code in all_codes:
        by_nomenclature[code['nomenclature']].append(code)
    
    for nomenclature, codes in by_nomenclature.items():
        output_file = output_dir / f"hierarchical_{nomenclature.lower()}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(codes, f, ensure_ascii=False, indent=2)
        print(f"✅ {output_file} ({len(codes):,} codes)")
    
    # 4. Export par niveau
    by_level = defaultdict(list)
    for code in all_codes:
        by_level[code['niveau']].append(code)
    
    print()
    for level, codes in sorted(by_level.items()):
        output_file = output_dir / f"niveau_{level}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(codes, f, ensure_ascii=False, indent=2)
        print(f"✅ {output_file} ({len(codes):,} codes)")
    
    # 5. CSV
    df_all = pd.DataFrame(all_codes)
    output_csv = output_dir / "nomenclatures_hierarchical_complete.csv"
    df_all.to_csv(output_csv, index=False, encoding='utf-8-sig')
    print(f"✅ {output_csv} ({len(all_codes):,} codes)")
    
    print()
    print("=" * 100)
    print("📊 STATISTIQUES HIÉRARCHIQUES")
    print("=" * 100)
    print()
    
    # Stats par nomenclature et niveau
    for nomenclature in sorted(by_nomenclature.keys()):
        codes = by_nomenclature[nomenclature]
        print(f"\n{nomenclature}:")
        print("-" * 80)
        
        level_counts = {}
        for code in codes:
            level = code['niveau']
            level_counts[level] = level_counts.get(level, 0) + 1
        
        for level in ['section', 'division', 'groupe', 'classe', 'sous_classe']:
            count = level_counts.get(level, 0)
            if count > 0:
                print(f"   {level:15s}: {count:5,} codes")
        
        print(f"   {'TOTAL':15s}: {len(codes):5,} codes")
    
    print()
    print("=" * 100)
    print(f"📊 TOTAL GÉNÉRAL: {len(all_codes):,} codes (tous niveaux)")
    print("=" * 100)
    print()
    print("🎯 AVANTAGES:")
    print("-" * 80)
    print("   ✅ Hiérarchie complète disponible")
    print("   ✅ Filtrage par section, division, groupe, classe")
    print("   ✅ Navigation parent -> enfants")
    print("   ✅ Recherche multi-niveaux")
    print("   ✅ Agrégations par niveau hiérarchique")
    print()
    print("=" * 100)

if __name__ == "__main__":
    extract_complete_hierarchical()

