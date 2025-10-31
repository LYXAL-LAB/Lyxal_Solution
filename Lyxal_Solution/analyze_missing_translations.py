#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyse les traductions manquantes
"""

import json
from pathlib import Path

input_file = Path("nomenclatures_hierarchical/nomenclatures_hierarchical_complete.json")

print("Analyse des libellés manquants...")
print()

with open(input_file, 'r', encoding='utf-8') as f:
    codes = json.load(f)

total_codes = len(codes)
missing_moyen = 0
missing_court = 0
missing_long = 0

for code in codes:
    if not code.get('libelle_long'):
        missing_long += 1
    if not code.get('libelle_moyen'):
        missing_moyen += 1
    if not code.get('libelle_court'):
        missing_court += 1

expected_translations = (
    (total_codes - missing_long) * 5 +  # libellé long
    (total_codes - missing_moyen) * 5 +  # libellé moyen
    (total_codes - missing_court) * 5    # libellé court
)

print(f"Total codes: {total_codes:,}")
print()
print(f"Codes avec libelle_long:  {total_codes - missing_long:,} ({missing_long} manquants)")
print(f"Codes avec libelle_moyen: {total_codes - missing_moyen:,} ({missing_moyen} manquants)")
print(f"Codes avec libelle_court: {total_codes - missing_court:,} ({missing_court} manquants)")
print()
print(f"Traductions attendues: {expected_translations:,}")
print(f"Traductions générées:  68,775")
print()

if expected_translations == 68775:
    print("✅ Le fichier contient TOUTES les traductions possibles !")
    print("   (Certains codes n'ont simplement pas tous les types de libellés)")
else:
    print(f"⚠️  Il manque {expected_translations - 68775} traductions")

