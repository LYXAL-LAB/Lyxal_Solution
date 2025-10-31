#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyse les champs SIRENE qui devraient être des tables de référence
"""

import json
from pathlib import Path
from collections import Counter

def analyze_sirene_fields():
    file_path = Path("Lyxal_Solution/dataset/StockUniteLegale_utf8.jsonl")
    
    print("=" * 100)
    print("ANALYSE DES CHAMPS SIRENE À CONVERTIR EN TABLES DE RÉFÉRENCE")
    print("=" * 100)
    print()
    
    # Champs à analyser
    fields_to_analyze = {
        'categorieJuridiqueUniteLegale': 'Forme juridique',
        'activitePrincipaleUniteLegale': 'Code NAF (déjà fait)',
        'nomenclatureActivitePrincipaleUniteLegale': 'Type nomenclature (déjà fait)',
        'trancheEffectifsUniteLegale': 'Tranche effectifs',
        'categorieEntreprise': 'Catégorie entreprise',
        'etatAdministratifUniteLegale': 'État administratif',
        'economieSocialeSolidaireUniteLegale': 'ESS',
        'sexeUniteLegale': 'Sexe',
        'caractereEmployeurUniteLegale': 'Caractère employeur'
    }
    
    sample_size = 50000
    field_values = {field: Counter() for field in fields_to_analyze.keys()}
    
    print(f"📊 Analyse de {sample_size:,} entreprises...")
    print()
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            if i >= sample_size:
                break
            
            if line.strip():
                record = json.loads(line)
                for field in fields_to_analyze.keys():
                    value = record.get(field)
                    if value:
                        field_values[field][value] += 1
    
    print("=" * 100)
    print("📋 RÉSULTATS - CHAMPS À CONVERTIR EN TABLES DE RÉFÉRENCE")
    print("=" * 100)
    print()
    
    for field, description in fields_to_analyze.items():
        print(f"\n{'='*100}")
        print(f"🔍 {field} - {description}")
        print('='*100)
        
        values = field_values[field]
        
        if not values:
            print("   ⚠️  Aucune valeur trouvée")
            continue
        
        print(f"   Valeurs distinctes: {len(values)}")
        print()
        
        if len(values) <= 50:  # Si peu de valeurs, c'est un bon candidat pour table de référence
            print("   ✅ BON CANDIDAT POUR TABLE DE RÉFÉRENCE")
            print()
            print("   Valeurs:")
            for value, count in sorted(values.items()):
                pct = (count / sample_size) * 100
                print(f"      '{value}': {count:,} ({pct:.2f}%)")
        else:
            print("   ⚠️  TROP DE VALEURS pour table de référence simple")
            print()
            print(f"   Top 20 valeurs:")
            for value, count in values.most_common(20):
                pct = (count / sample_size) * 100
                print(f"      '{value}': {count:,} ({pct:.2f}%)")
    
    print()
    print()
    print("=" * 100)
    print("🎯 RECOMMANDATIONS")
    print("=" * 100)
    print()
    
    print("Tables de référence à créer:")
    print()
    
    recommendations = [
        ("✅ FAIT", "business_nomenclature_type", "Types de nomenclatures (NAFRev2, NAP, etc.)"),
        ("✅ FAIT", "business_hierarchical_level", "Niveaux hiérarchiques (section, division, etc.)"),
        ("✅ FAIT", "business_activity_code", "Codes d'activité NAF/NAP"),
        ("", "", ""),
        ("📋 À FAIRE", "business_legal_form", "Formes juridiques (SARL, SAS, EI, etc.)"),
        ("📋 À FAIRE", "business_workforce_range", "Tranches d'effectifs (0, 1-2, 3-5, etc.)"),
        ("📋 À FAIRE", "business_company_category", "Catégories d'entreprise (PME, ETI, GE)"),
        ("📋 À FAIRE", "business_administrative_status", "États administratifs (A=Actif, C=Cessé)"),
        ("📋 À FAIRE", "business_ess_status", "Statut ESS (Oui/Non)"),
        ("📋 À FAIRE", "business_gender", "Sexe (pour entrepreneurs individuels)"),
    ]
    
    for status, table, description in recommendations:
        if status:
            print(f"   {status:12s} {table:35s} - {description}")
    
    print()
    print("=" * 100)

if __name__ == "__main__":
    analyze_sirene_fields()

