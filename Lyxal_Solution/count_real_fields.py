#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Compte le nombre RÉEL de champs par ligne (non-null)
"""

import json
from pathlib import Path
from collections import Counter

def count_real_fields():
    file_path = Path("Lyxal_Solution/jeux de données/StockUniteLegale_utf8.jsonl")
    
    print("=" * 100)
    print("ANALYSE DU NOMBRE RÉEL DE CHAMPS PAR LIGNE")
    print("=" * 100)
    print()
    
    # Statistiques
    total_fields_per_line = []  # Nombre total de clés par ligne
    non_null_fields_per_line = []  # Nombre de champs non-null par ligne
    field_presence = Counter()  # Compteur de présence par champ
    field_non_null = Counter()  # Compteur de valeurs non-null par champ
    
    sample_size = 100000  # Analyser 100k lignes pour avoir des stats fiables
    
    print(f"⏳ Analyse de {sample_size:,} lignes...")
    print()
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            if i >= sample_size:
                break
                
            if line.strip():
                record = json.loads(line)
                
                # Compter le nombre total de clés
                total_keys = len(record.keys())
                total_fields_per_line.append(total_keys)
                
                # Compter les champs non-null
                non_null_count = 0
                for key, value in record.items():
                    field_presence[key] += 1
                    if value is not None and value != '':
                        non_null_count += 1
                        field_non_null[key] += 1
                
                non_null_fields_per_line.append(non_null_count)
            
            if (i + 1) % 10000 == 0:
                print(f"   ... {i+1:,} lignes analysées")
    
    print()
    print("=" * 100)
    print("📊 RÉSULTATS")
    print("=" * 100)
    print()
    
    # Nombre total de champs (clés) par ligne
    min_total = min(total_fields_per_line)
    max_total = max(total_fields_per_line)
    avg_total = sum(total_fields_per_line) / len(total_fields_per_line)
    
    print(f"🔢 NOMBRE DE CHAMPS (CLÉS) PAR LIGNE:")
    print("-" * 80)
    print(f"   Minimum:  {min_total} champs")
    print(f"   Maximum:  {max_total} champs")
    print(f"   Moyenne:  {avg_total:.1f} champs")
    print()
    
    # Distribution
    total_counter = Counter(total_fields_per_line)
    print(f"   Distribution:")
    for count, occurrences in sorted(total_counter.items()):
        pct = (occurrences / len(total_fields_per_line)) * 100
        print(f"      {count} champs: {occurrences:,} lignes ({pct:.1f}%)")
    
    print()
    print()
    
    # Nombre de champs NON-NULL par ligne
    min_non_null = min(non_null_fields_per_line)
    max_non_null = max(non_null_fields_per_line)
    avg_non_null = sum(non_null_fields_per_line) / len(non_null_fields_per_line)
    
    print(f"✅ NOMBRE DE CHAMPS NON-NULL (avec valeur) PAR LIGNE:")
    print("-" * 80)
    print(f"   Minimum:  {min_non_null} champs")
    print(f"   Maximum:  {max_non_null} champs")
    print(f"   Moyenne:  {avg_non_null:.1f} champs")
    print()
    
    # Distribution
    non_null_counter = Counter(non_null_fields_per_line)
    print(f"   Distribution (top 10):")
    for count, occurrences in sorted(non_null_counter.items(), key=lambda x: x[1], reverse=True)[:10]:
        pct = (occurrences / len(non_null_fields_per_line)) * 100
        print(f"      {count} champs: {occurrences:,} lignes ({pct:.1f}%)")
    
    print()
    print()
    print("=" * 100)
    print("📋 PRÉSENCE DES CHAMPS (sur échantillon de 100k lignes)")
    print("=" * 100)
    print()
    
    print("Champ                                           | Présent      | Non-Null     | % Rempli")
    print("-" * 100)
    
    for field in sorted(field_presence.keys()):
        present = field_presence[field]
        non_null = field_non_null[field]
        pct_present = (present / sample_size) * 100
        pct_non_null = (non_null / sample_size) * 100
        
        print(f"{field:45s} | {present:8,}     | {non_null:8,}     | {pct_non_null:5.1f}%")
    
    print()
    print()
    print("=" * 100)
    print("🎯 RÉPONSE À VOTRE QUESTION")
    print("=" * 100)
    print()
    print(f"📌 Chaque ligne contient TOUJOURS:  {max_total} CHAMPS (clés)")
    print()
    print(f"📌 Mais en moyenne, seulement {avg_non_null:.1f} champs ont une valeur (non-null)")
    print()
    print(f"   → Taux de remplissage moyen: {(avg_non_null / max_total * 100):.1f}%")
    print()
    print("=" * 100)
    
    # Top champs les plus remplis
    print()
    print("🏆 TOP 10 DES CHAMPS LES PLUS REMPLIS:")
    print("-" * 80)
    for field, count in field_non_null.most_common(10):
        pct = (count / sample_size) * 100
        print(f"   {field:45s}: {pct:5.1f}%")
    
    print()
    print()
    print("🚫 TOP 10 DES CHAMPS LES MOINS REMPLIS (souvent null):")
    print("-" * 80)
    sorted_fields = sorted(field_non_null.items(), key=lambda x: x[1])
    for field, count in sorted_fields[:10]:
        pct = (count / sample_size) * 100
        print(f"   {field:45s}: {pct:5.1f}%")
    
    print()

if __name__ == "__main__":
    count_real_fields()

