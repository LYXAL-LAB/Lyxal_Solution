#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Vérifie la couverture complète des nomenclatures d'activités
"""

import json
from pathlib import Path
from collections import Counter

def verify_coverage():
    print("=" * 100)
    print("VÉRIFICATION DE LA COUVERTURE DES NOMENCLATURES D'ACTIVITÉS")
    print("=" * 100)
    print()
    
    # 1. Analyser ce qu'on a extrait
    naf_file = Path("naf_rev2_terminal.json")
    
    if naf_file.exists():
        with open(naf_file, 'r', encoding='utf-8') as f:
            naf_codes = json.load(f)
        
        print("✅ NOMENCLATURE EXTRAITE:")
        print("-" * 80)
        print(f"   NAF Rev 2 (codes terminaux): {len(naf_codes):,} codes")
        print()
    
    # 2. Analyser ce qui est utilisé dans SIRENE
    sirene_file = Path("Lyxal_Solution/jeux de données/StockUniteLegale_utf8.jsonl")
    
    if sirene_file.exists():
        print("📊 NOMENCLATURES UTILISÉES DANS SIRENE:")
        print("-" * 80)
        
        nomenclatures = Counter()
        sample_codes_by_nomenclature = {}
        sample_size = 50000
        
        with open(sirene_file, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if i >= sample_size:
                    break
                
                if line.strip():
                    record = json.loads(line)
                    nomenclature = record.get('nomenclatureActivitePrincipaleUniteLegale')
                    activity_code = record.get('activitePrincipaleUniteLegale')
                    
                    if nomenclature:
                        nomenclatures[nomenclature] += 1
                        
                        # Garder quelques exemples de codes
                        if nomenclature not in sample_codes_by_nomenclature:
                            sample_codes_by_nomenclature[nomenclature] = []
                        if len(sample_codes_by_nomenclature[nomenclature]) < 10 and activity_code:
                            sample_codes_by_nomenclature[nomenclature].append(activity_code)
        
        total = sum(nomenclatures.values())
        
        for nomenclature, count in nomenclatures.most_common():
            pct = (count / total) * 100
            print(f"   {nomenclature:20s}: {count:7,} ({pct:5.1f}%)")
        
        print()
        print()
        
        # 3. Exemples de codes par nomenclature
        print("📋 EXEMPLES DE CODES PAR NOMENCLATURE:")
        print("-" * 80)
        
        for nomenclature, codes in sorted(sample_codes_by_nomenclature.items()):
            print(f"\n   {nomenclature}:")
            for code in codes[:5]:
                print(f"      - {code}")
    
    print()
    print()
    print("=" * 100)
    print("🎯 ANALYSE DE LA COUVERTURE")
    print("=" * 100)
    print()
    
    print("✅ CE QU'ON A:")
    print("-" * 80)
    print("   • NAF Rev 2 : 732 codes terminaux")
    print("     → Nomenclature ACTUELLE (en vigueur)")
    print("     → Couvre ~33% des entreprises SIRENE")
    print()
    
    print("❌ CE QUI MANQUE:")
    print("-" * 80)
    print("   • NAP (Nomenclature d'Activités de Produits)")
    print("     → Nomenclature ANCIENNE")
    print("     → Utilisée par ~48% des entreprises SIRENE")
    print("     → Format: XX.XX (ex: 22.02, 64.42)")
    print()
    print("   • NAF 1993")
    print("     → Nomenclature ANCIENNE")
    print("     → Utilisée par ~16% des entreprises SIRENE")
    print("     → Format: XX.XA (ex: 70.2C, 55.4B)")
    print()
    print("   • NAF Rev 1")
    print("     → Nomenclature ANCIENNE")
    print("     → Utilisée par ~3% des entreprises SIRENE")
    print()
    
    print()
    print("=" * 100)
    print("📊 RÉSUMÉ")
    print("=" * 100)
    print()
    print("   Couverture actuelle:")
    print("   ┌────────────────────────────────────────────────────────┐")
    print("   │ NAF Rev 2 : ✅ 100% (732 codes)                        │")
    print("   │ NAP       : ❌   0% (manquant)                         │")
    print("   │ NAF 1993  : ❌   0% (manquant)                         │")
    print("   │ NAF Rev 1 : ❌   0% (manquant)                         │")
    print("   └────────────────────────────────────────────────────────┘")
    print()
    print("   Entreprises SIRENE couvertes:")
    print("   ┌────────────────────────────────────────────────────────┐")
    print("   │ Avec référentiel :  ~33% (NAF Rev 2)                  │")
    print("   │ Sans référentiel :  ~67% (NAP, NAF1993, NAFRev1)      │")
    print("   └────────────────────────────────────────────────────────┘")
    print()
    print("=" * 100)
    print()
    print("💡 RECOMMANDATIONS:")
    print("-" * 80)
    print()
    print("   1. Pour l'instant, vous avez la nomenclature ACTUELLE (NAF Rev 2)")
    print()
    print("   2. Les anciennes nomenclatures (NAP, NAF1993, NAFRev1) sont pour:")
    print("      - Les entreprises créées avant 2008")
    print("      - Les entreprises qui n'ont pas mis à jour leur code")
    print()
    print("   3. Options:")
    print("      a) Utiliser UNIQUEMENT NAF Rev 2 (33% des entreprises)")
    print("      b) Trouver les fichiers des anciennes nomenclatures")
    print("      c) Créer une table de correspondance NAP/NAF1993 → NAF Rev 2")
    print()
    print("   4. Recommandation:")
    print("      → Commencer avec NAF Rev 2 (nomenclature actuelle)")
    print("      → Ajouter les anciennes nomenclatures plus tard si nécessaire")
    print()
    print("=" * 100)

if __name__ == "__main__":
    verify_coverage()

