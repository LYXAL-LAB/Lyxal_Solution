#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Vérifie le format des codes d'activité économique
"""

import json
from pathlib import Path
from collections import Counter

def check_activity_format():
    file_path = Path("Lyxal_Solution/jeux de données/StockUniteLegale_utf8.jsonl")
    
    print("=" * 100)
    print("ANALYSE DES CODES D'ACTIVITÉ ÉCONOMIQUE")
    print("=" * 100)
    print()
    
    activity_codes = []
    nomenclature_types = Counter()
    sample_count = 10000
    
    print(f"⏳ Analyse de {sample_count:,} lignes...")
    print()
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            if i >= sample_count:
                break
                
            if line.strip():
                record = json.loads(line)
                
                activity = record.get('activitePrincipaleUniteLegale')
                nomenclature = record.get('nomenclatureActivitePrincipaleUniteLegale')
                
                if activity:
                    activity_codes.append({
                        'code': activity,
                        'type': type(activity).__name__,
                        'nomenclature': nomenclature
                    })
                    
                if nomenclature:
                    nomenclature_types[nomenclature] += 1
    
    print("=" * 100)
    print("📊 RÉSULTATS")
    print("=" * 100)
    print()
    
    # Type de données
    print("🔍 TYPE DE DONNÉES:")
    print("-" * 80)
    if activity_codes:
        data_type = activity_codes[0]['type']
        print(f"   Type Python: {data_type}")
        print(f"   → Les codes sont stockés en: {'STRING (texte)' if data_type == 'str' else data_type}")
    print()
    
    # Exemples de codes
    print("📋 EXEMPLES DE CODES (30 premiers):")
    print("-" * 80)
    for i, item in enumerate(activity_codes[:30], 1):
        print(f"   {i:2d}. '{item['code']}' (nomenclature: {item['nomenclature']})")
    print()
    
    # Distribution des nomenclatures
    print("=" * 100)
    print("📚 TYPES DE NOMENCLATURES")
    print("=" * 100)
    print()
    for nomenclature, count in nomenclature_types.most_common():
        pct = (count / sample_count) * 100
        print(f"   {nomenclature:20s}: {count:6,} occurrences ({pct:5.1f}%)")
    print()
    
    # Analyse de la structure des codes
    print("=" * 100)
    print("🔬 STRUCTURE DES CODES APE/NAF")
    print("=" * 100)
    print()
    
    code_lengths = Counter([len(str(item['code'])) for item in activity_codes if item['code']])
    code_patterns = Counter()
    
    for item in activity_codes:
        code = str(item['code'])
        # Analyser le pattern
        pattern = ''
        for char in code:
            if char.isdigit():
                pattern += 'N'
            elif char.isalpha():
                pattern += 'A'
            elif char == '.':
                pattern += '.'
            else:
                pattern += 'X'
        code_patterns[pattern] += 1
    
    print("Longueur des codes:")
    print("-" * 80)
    for length, count in sorted(code_lengths.items()):
        pct = (count / len(activity_codes)) * 100
        print(f"   {length} caractères: {count:,} codes ({pct:.1f}%)")
    print()
    
    print("Patterns de codes (top 10):")
    print("-" * 80)
    for pattern, count in code_patterns.most_common(10):
        pct = (count / len(activity_codes)) * 100
        # Exemples
        examples = [item['code'] for item in activity_codes if len(str(item['code'])) == len(pattern)][:3]
        examples_str = ', '.join([f"'{ex}'" for ex in examples[:3]])
        print(f"   {pattern:15s}: {count:6,} codes ({pct:5.1f}%) - Ex: {examples_str}")
    print()
    
    # Statistiques uniques
    unique_codes = set(item['code'] for item in activity_codes if item['code'])
    print("=" * 100)
    print("📊 STATISTIQUES")
    print("=" * 100)
    print()
    print(f"   Codes analysés:      {len(activity_codes):,}")
    print(f"   Codes uniques:       {len(unique_codes):,}")
    print(f"   Format:              STRING (texte)")
    print()
    
    print("=" * 100)
    print("🎯 RÉPONSE À VOTRE QUESTION")
    print("=" * 100)
    print()
    print("   ❓ Format des codes d'activité économique:")
    print()
    print("   ✅ Type: STRING (texte)")
    print()
    print("   ✅ Format standard: 'XX.XXA' (ex: '32.12Z', '85.59A')")
    print("      - 2 chiffres")
    print("      - 1 point")
    print("      - 2 chiffres")
    print("      - 1 lettre (optionnelle)")
    print()
    print("   📌 Ce SONT des codes, PAS des IDs numériques")
    print()
    print("   💡 Pour SurrealDB:")
    print("      - Stocker en STRING")
    print("      - Créer une table de référence 'base_activity_code'")
    print("      - Faire une relation: unite_legale -> activity_code")
    print()
    print("=" * 100)
    
    # Top 20 des codes les plus fréquents
    code_frequency = Counter(item['code'] for item in activity_codes if item['code'])
    print()
    print("🏆 TOP 20 DES CODES APE/NAF LES PLUS FRÉQUENTS:")
    print("-" * 80)
    for code, count in code_frequency.most_common(20):
        pct = (count / len(activity_codes)) * 100
        print(f"   {code:10s}: {count:5,} entreprises ({pct:5.2f}%)")
    print()

if __name__ == "__main__":
    check_activity_format()

