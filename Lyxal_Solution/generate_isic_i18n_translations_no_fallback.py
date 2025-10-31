#!/usr/bin/env python3
"""
Génère les traductions i18n pour les codes ISIC internationaux
SANS FALLBACK - seulement les langues réellement disponibles
"""
import urllib.request
import csv
import re

def slugify(text):
    """Crée un slug pour les IDs SurrealDB"""
    text = text.lower()
    text = re.sub(r'[^a-z0-9_]', '_', text)
    text = re.sub(r'_+', '_', text)
    return text.strip('_')

def download_file(url, encoding='latin-1'):
    """Télécharge et décode un fichier"""
    print(f"📥 {url.split('/')[-1]}...")
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read().decode(encoding)
            return content
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        return None

def parse_csv_content(content):
    """Parse le contenu CSV"""
    codes_dict = {}
    lines = content.strip().split('\n')
    
    # Vérifie si c'est un vrai CSV avec virgules
    if '","' in lines[0] or '",' in lines[0]:
        # Format CSV standard
        reader = csv.DictReader(lines)
        
        # Détecte les noms de colonnes
        fieldnames = reader.fieldnames
        code_field = None
        desc_field = None
        
        for field in fieldnames:
            field_lower = field.lower()
            if 'code' in field_lower or 'cod' in field_lower:
                code_field = field
            if 'desc' in field_lower or 'title' in field_lower or 'libel' in field_lower:
                desc_field = field
        
        # Fallback sur les deux premières colonnes
        if not code_field or not desc_field:
            code_field = fieldnames[0] if len(fieldnames) > 0 else 'Code'
            desc_field = fieldnames[1] if len(fieldnames) > 1 else 'Description'
        
        for row in reader:
            try:
                code = row[code_field].strip('"').strip()
                description = row[desc_field].strip('"').strip()
                codes_dict[code] = description
            except (KeyError, IndexError):
                continue
    else:
        # Format texte avec espaces fixes
        for i, line in enumerate(lines):
            if i == 0:  # Skip header
                continue
            line = line.strip()
            if not line:
                continue
            parts = line.split(maxsplit=1)
            if len(parts) < 2:
                continue
            code = parts[0].strip()
            description = parts[1].strip()
            codes_dict[code] = description
    
    return codes_dict

def generate_translations(output_file):
    """Génère le fichier .surql avec toutes les traductions SANS FALLBACK"""
    
    # Fichiers ISIC par langue - SEULEMENT ceux qui existent
    isic_files = {
        'isic_rev4': {
            'fr': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_French_structure.Txt',
            'en': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_english_structure.txt',
            'es': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_spanish_structure.txt',
            'code': 'ISIC Rev. 4'
        },
        'isic_rev3_1': {
            'en': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_1_english_structure.txt',
            'code': 'ISIC Rev. 3.1'
        },
        'isic_rev3': {
            'fr': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/CITI_Rev_3_french_structure.txt',
            'en': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_english_structure.txt',
            'code': 'ISIC Rev. 3'
        },
        'isic_rev2': {
            'fr': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/CITI_Rev_2_french_structure.txt',
            'en': 'https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_2_english_structure.txt',
            'code': 'ISIC Rev. 2'
        }
    }
    
    # Langues disponibles et leurs codes
    lang_map = {
        'fr': 'language:fr',
        'en': 'language:en',
        'es': 'language:es',
        'de': 'language:de',
        'it': 'language:it'
    }
    
    total_translations = 0
    
    with open(output_file, 'w', encoding='utf-8') as f:
        # Header
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: activity_code (INTERNATIONAL - ISIC)\n")
        f.write("-- Source: Nations Unies (unstats.un.org)\n")
        f.write("-- SANS FALLBACK - Seulement les langues officiellement disponibles\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        # Pour chaque révision ISIC
        for key, info in isic_files.items():
            print(f"\n{'='*80}")
            print(f"📂 {info['code']}")
            print(f"{'='*80}")
            
            f.write("-- " + "-" * 97 + "\n")
            f.write(f"-- {info['code']}\n")
            f.write("-- " + "-" * 97 + "\n\n")
            
            # Télécharge les fichiers dans chaque langue disponible
            translations_by_code = {}
            available_langs = []
            
            for lang_code, url in info.items():
                if lang_code == 'code':
                    continue
                
                content = download_file(url)
                if content:
                    codes_dict = parse_csv_content(content)
                    print(f"   ✅ {lang_code.upper()}: {len(codes_dict)} codes")
                    available_langs.append(lang_code)
                    
                    for code, description in codes_dict.items():
                        if code not in translations_by_code:
                            translations_by_code[code] = {}
                        translations_by_code[code][lang_code] = description
            
            print(f"   📝 Langues disponibles: {', '.join([l.upper() for l in available_langs])}")
            
            # Génère les RELATE SEULEMENT pour les langues qui existent
            for code, translations in sorted(translations_by_code.items()):
                code_slug = slugify(code)
                record_id = f"{key}_{code_slug}"
                i18n_key = f"i18n_key:activity_code_{record_id}_long"
                
                # Pour chaque langue RÉELLEMENT disponible
                for lang_code, text in translations.items():
                    lang_id = lang_map[lang_code]
                    # Échappe les apostrophes pour SQL
                    text_escaped = text.replace("'", "\\'")
                    f.write(f"RELATE {i18n_key}->i18n_translation->{lang_id}\n")
                    f.write(f"    SET text = '{text_escaped}';\n\n")
                    total_translations += 1
    
    print(f"\n✅ Fichier généré: {output_file}")
    print(f"   Total: {total_translations:,} traductions (SANS FALLBACK)")

def main():
    print("🚀 Génération des traductions i18n ISIC (SANS FALLBACK)\n")
    print("⏳ Cela peut prendre quelques minutes...\n")
    
    output_file = 'Lyxal_Solution/Lyxal_Surreal/base/reference/activity/international/activity_code_i18n_translations_international.surql'
    generate_translations(output_file)
    
    print("\n✅ Terminé !")

if __name__ == '__main__':
    main()

