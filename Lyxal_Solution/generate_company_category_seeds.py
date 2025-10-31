#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère les seeds avec i18n pour les catégories d'entreprises
Source: Article 51 de la loi de modernisation de l'économie
"""

from pathlib import Path

ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    return s.replace("'", "\\'")

# 4 Catégories officielles (Article 51 de la loi de modernisation de l'économie)
COMPANY_CATEGORIES = [
    {
        'code': 'MIC',
        'min_employees': 0,
        'max_employees': 9,
        'max_revenue': 2,
        'max_balance': 2,
        'sort_order': 1,
        'name': {
            'fr': 'Microentreprise',
            'en': 'Microenterprise',
            'es': 'Microempresa',
            'de': 'Kleinstunternehmen',
            'it': 'Microimpresa'
        },
        'description': {
            'fr': 'Entreprise occupant moins de 10 personnes, et qui a un chiffre d\'affaires annuel ou un total de bilan n\'excédant pas 2 millions d\'euros',
            'en': 'Enterprise with fewer than 10 employees, and with annual turnover or total balance sheet not exceeding 2 million euros',
            'es': 'Empresa con menos de 10 empleados, y con volumen de negocio anual o balance total que no exceda de 2 millones de euros',
            'de': 'Unternehmen mit weniger als 10 Beschäftigten und einem Jahresumsatz oder einer Bilanzsumme von höchstens 2 Millionen Euro',
            'it': 'Impresa con meno di 10 dipendenti e con fatturato annuo o totale di bilancio non superiore a 2 milioni di euro'
        }
    },
    {
        'code': 'PME',
        'min_employees': 0,
        'max_employees': 249,
        'max_revenue': 50,
        'max_balance': 43,
        'sort_order': 2,
        'name': {
            'fr': 'Petite ou Moyenne Entreprise',
            'en': 'Small or Medium Enterprise',
            'es': 'Pequeña o Mediana Empresa',
            'de': 'Kleine oder mittlere Unternehmen',
            'it': 'Piccola o Media Impresa'
        },
        'description': {
            'fr': 'Entreprise occupant moins de 250 personnes, et qui a un chiffre d\'affaires annuel inférieur à 50 millions d\'euros ou un total de bilan n\'excédant pas 43 millions d\'euros',
            'en': 'Enterprise with fewer than 250 employees, and with annual turnover less than 50 million euros or total balance sheet not exceeding 43 million euros',
            'es': 'Empresa con menos de 250 empleados, y con volumen de negocio anual inferior a 50 millones de euros o balance total que no exceda de 43 millones de euros',
            'de': 'Unternehmen mit weniger als 250 Beschäftigten und einem Jahresumsatz von weniger als 50 Millionen Euro oder einer Bilanzsumme von höchstens 43 Millionen Euro',
            'it': 'Impresa con meno di 250 dipendenti e con fatturato annuo inferiore a 50 milioni di euro o totale di bilancio non superiore a 43 milioni di euro'
        }
    },
    {
        'code': 'ETI',
        'min_employees': 250,
        'max_employees': 4999,
        'max_revenue': 1500,
        'max_balance': 2000,
        'sort_order': 3,
        'name': {
            'fr': 'Entreprise de Taille Intermédiaire',
            'en': 'Mid-sized Enterprise',
            'es': 'Empresa de Tamaño Intermedio',
            'de': 'Mittelständisches Unternehmen',
            'it': 'Impresa di Dimensioni Intermedie'
        },
        'description': {
            'fr': 'Entreprise ayant entre 250 et 4 999 salariés, et soit un chiffre d\'affaires annuel n\'excédant pas 1,5 milliard d\'euros, soit un total de bilan n\'excédant pas 2 milliards d\'euros. Une entreprise de moins de 250 salariés mais avec plus de 50 millions d\'euros de CA et plus de 43 millions d\'euros de bilan est aussi considérée comme une ETI',
            'en': 'Enterprise with between 250 and 4,999 employees, and either annual turnover not exceeding 1.5 billion euros, or total balance sheet not exceeding 2 billion euros. An enterprise with fewer than 250 employees but with more than 50 million euros turnover and more than 43 million euros balance sheet is also considered a mid-sized enterprise',
            'es': 'Empresa con entre 250 y 4.999 empleados, y con volumen de negocio anual que no exceda de 1.500 millones de euros, o balance total que no exceda de 2.000 millones de euros. Una empresa con menos de 250 empleados pero con más de 50 millones de euros de volumen de negocio y más de 43 millones de euros de balance también se considera ETI',
            'de': 'Unternehmen mit 250 bis 4.999 Beschäftigten und entweder einem Jahresumsatz von höchstens 1,5 Milliarden Euro oder einer Bilanzsumme von höchstens 2 Milliarden Euro. Ein Unternehmen mit weniger als 250 Beschäftigten, aber mehr als 50 Millionen Euro Umsatz und mehr als 43 Millionen Euro Bilanzsumme gilt ebenfalls als mittelständisches Unternehmen',
            'it': 'Impresa con tra 250 e 4.999 dipendenti, e con fatturato annuo non superiore a 1,5 miliardi di euro, o totale di bilancio non superiore a 2 miliardi di euro. Un\'impresa con meno di 250 dipendenti ma con più di 50 milioni di euro di fatturato e più di 43 milioni di euro di bilancio è considerata anche un\'impresa di dimensioni intermedie'
        }
    },
    {
        'code': 'GE',
        'min_employees': 5000,
        'max_employees': None,
        'max_revenue': None,
        'max_balance': None,
        'sort_order': 4,
        'name': {
            'fr': 'Grande Entreprise',
            'en': 'Large Enterprise',
            'es': 'Gran Empresa',
            'de': 'Großunternehmen',
            'it': 'Grande Impresa'
        },
        'description': {
            'fr': 'Entreprise ayant au moins 5 000 salariés. Une entreprise qui a moins de 5 000 salariés mais plus de 1,5 milliard d\'euros de chiffre d\'affaires et plus de 2 milliards d\'euros de total de bilan est aussi considérée comme une grande entreprise',
            'en': 'Enterprise with at least 5,000 employees. An enterprise with fewer than 5,000 employees but with more than 1.5 billion euros turnover and more than 2 billion euros balance sheet is also considered a large enterprise',
            'es': 'Empresa con al menos 5.000 empleados. Una empresa con menos de 5.000 empleados pero con más de 1.500 millones de euros de volumen de negocio y más de 2.000 millones de euros de balance total también se considera una gran empresa',
            'de': 'Unternehmen mit mindestens 5.000 Beschäftigten. Ein Unternehmen mit weniger als 5.000 Beschäftigten, aber mehr als 1,5 Milliarden Euro Umsatz und mehr als 2 Milliarden Euro Bilanzsumme gilt ebenfalls als Großunternehmen',
            'it': 'Impresa con almeno 5.000 dipendenti. Un\'impresa con meno di 5.000 dipendenti ma con più di 1,5 miliardi di euro di fatturato e più di 2 miliardi di euro di bilancio totale è considerata anche una grande impresa'
        }
    }
]

def generate_company_category_seeds():
    """Génère tous les seeds pour les catégories d'entreprises"""
    
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    
    print("=" * 100)
    print("GÉNÉRATION DES SEEDS POUR LES CATÉGORIES D'ENTREPRISES")
    print("=" * 100)
    print()
    
    print(f"✅ {len(COMPANY_CATEGORIES)} catégories (Article 51 - Loi de modernisation de l'économie)")
    print()
    
    # === i18n keys ===
    i18n_keys_file = output_dir / "business_company_category_i18n_keys.surql"
    
    print("1️⃣  Génération des i18n keys...")
    
    with open(i18n_keys_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N KEYS: business_company_category\n")
        f.write(f"-- Total: {len(COMPANY_CATEGORIES)} catégories d'entreprises\n")
        f.write("-- Source: Article 51 de la loi de modernisation de l'économie\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for cat in COMPANY_CATEGORIES:
            name_key = f"i18n_company_category_{cat['code'].lower()}_name"
            desc_key = f"i18n_company_category_{cat['code'].lower()}_description"
            
            f.write(f"CREATE i18n_key:{name_key} SET\n")
            f.write(f"    description = 'Nom de la catégorie {cat['code']}: {escape_string(cat['name']['fr'])}';\n\n")
            
            f.write(f"CREATE i18n_key:{desc_key} SET\n")
            f.write(f"    description = 'Description de la catégorie {cat['code']}';\n\n")
    
    print(f"   ✅ {len(COMPANY_CATEGORIES) * 2} i18n keys générées (nom + description)")
    print()
    
    # === i18n translations ===
    i18n_trans_file = output_dir / "business_company_category_i18n_translations.surql"
    
    print("2️⃣  Génération des i18n translations...")
    
    with open(i18n_trans_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_company_category\n")
        f.write(f"-- Total: {len(COMPANY_CATEGORIES)} × 2 (nom + desc) × 5 langues = {len(COMPANY_CATEGORIES) * 2 * 5} traductions\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for cat in COMPANY_CATEGORIES:
            name_key = f"i18n_company_category_{cat['code'].lower()}_name"
            desc_key = f"i18n_company_category_{cat['code'].lower()}_description"
            
            f.write(f"-- Catégorie {cat['code']}: {cat['name']['fr']}\n")
            f.write("-" * 100 + "\n\n")
            
            # Noms
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{name_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(cat['name'][lang])}';\n\n")
            
            # Descriptions
            for lang in ACTIVE_LANGUAGES:
                f.write(f"RELATE i18n_key:{desc_key}->i18n_translation->i18n_language:{lang}\n")
                f.write(f"    SET text = '{escape_string(cat['description'][lang])}';\n\n")
    
    print(f"   ✅ {len(COMPANY_CATEGORIES) * 2 * 5} traductions générées")
    print()
    
    # === Seeds ===
    seeds_file = output_dir / "business_company_category_seeds.surql"
    
    print("3️⃣  Génération des seeds...")
    
    with open(seeds_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- SEEDS: business_company_category\n")
        f.write(f"-- Total: {len(COMPANY_CATEGORIES)} catégories d'entreprises\n")
        f.write("-- Source: Article 51 de la loi de modernisation de l'économie\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        for cat in COMPANY_CATEGORIES:
            name_key = f"i18n_company_category_{cat['code'].lower()}_name"
            desc_key = f"i18n_company_category_{cat['code'].lower()}_description"
            
            min_val = str(cat['min_employees']) if cat['min_employees'] is not None else 'NONE'
            max_val = str(cat['max_employees']) if cat['max_employees'] is not None else 'NONE'
            max_rev = str(cat['max_revenue']) if cat['max_revenue'] is not None else 'NONE'
            max_bal = str(cat['max_balance']) if cat['max_balance'] is not None else 'NONE'
            
            f.write(f"CREATE business_company_category:cat_{cat['code'].lower()} SET\n")
            f.write(f"    code = '{cat['code']}',\n")
            f.write(f"    name_i18n_key = i18n_key:{name_key},\n")
            f.write(f"    description_i18n_key = i18n_key:{desc_key},\n")
            f.write(f"    min_employees = {min_val},\n")
            f.write(f"    max_employees = {max_val},\n")
            f.write(f"    max_revenue_millions = {max_rev},\n")
            f.write(f"    max_balance_millions = {max_bal},\n")
            f.write(f"    sort_order = {cat['sort_order']};\n\n")
    
    print(f"   ✅ {len(COMPANY_CATEGORIES)} seeds générés")
    print()
    
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print("📁 Fichiers générés:")
    print()
    print(f"  - business_company_category_i18n_keys.surql ({len(COMPANY_CATEGORIES) * 2} keys)")
    print(f"  - business_company_category_i18n_translations.surql ({len(COMPANY_CATEGORIES) * 2 * 5} traductions)")
    print(f"  - business_company_category_seeds.surql ({len(COMPANY_CATEGORIES)} seeds)")
    print()
    print("📊 Détail des catégories:")
    print()
    for cat in COMPANY_CATEGORIES:
        emp = f"{cat['min_employees']}-{cat['max_employees'] if cat['max_employees'] else '∞'} salariés"
        rev = f"CA ≤ {cat['max_revenue']}M€" if cat['max_revenue'] else "CA illimité"
        bal = f"Bilan ≤ {cat['max_balance']}M€" if cat['max_balance'] else "Bilan illimité"
        print(f"   {cat['code']}: {cat['name']['fr']:.<35} [{emp}, {rev}, {bal}]")
    print()
    print("💡 NOTE: Le champ categorieEntreprise dans SIRENE peut être NULL pour les microentreprises")
    print("         qui ne déclarent pas leurs effectifs ou leur CA.")
    print()
    print("=" * 100)

if __name__ == "__main__":
    generate_company_category_seeds()

