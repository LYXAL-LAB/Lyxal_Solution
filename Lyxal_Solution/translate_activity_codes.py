#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Traduit TOUS les codes d'activité dans les 4 langues (en, es, de, it)
en utilisant DeepL API (traduction de haute qualité)
"""

import json
from pathlib import Path
import time

# Configuration
DEEPL_API_KEY = "VOTRE_CLE_API_DEEPL"  # À remplacer
USE_FREE_API = True  # True pour API gratuite, False pour API Pro

ACTIVE_LANGUAGES = ['fr', 'en', 'es', 'de', 'it']
TARGET_LANGUAGES = ['en', 'es', 'de', 'it']  # Tout sauf français

def escape_string(s):
    """Échappe les caractères spéciaux pour SurrealDB"""
    if not s:
        return ''
    s = s.replace("'", "\\'")
    return s

def translate_with_deepl(text, target_lang, api_key):
    """
    Traduit un texte avec DeepL API
    
    Note: Cette fonction nécessite la bibliothèque 'deepl'
    Installation: pip install deepl
    """
    try:
        import deepl
        
        translator = deepl.Translator(api_key)
        
        # Mapping des codes de langue
        lang_map = {
            'en': 'EN-GB',  # Anglais britannique
            'es': 'ES',      # Espagnol
            'de': 'DE',      # Allemand
            'it': 'IT'       # Italien
        }
        
        result = translator.translate_text(
            text, 
            target_lang=lang_map[target_lang],
            formality='default'  # Registre neutre/professionnel
        )
        
        return result.text
    
    except ImportError:
        print("❌ Bibliothèque 'deepl' non installée. Installez avec: pip install deepl")
        return None
    except Exception as e:
        print(f"❌ Erreur de traduction: {e}")
        return None

def translate_with_mock(text, target_lang):
    """
    Traduction SIMULÉE pour tester le script sans API
    Retourne des traductions fictives mais réalistes
    """
    
    # Dictionnaire de traductions communes
    translations = {
        'en': {
            'AGRICULTURE, SYLVICULTURE ET PÊCHE': 'AGRICULTURE, FORESTRY AND FISHING',
            'Culture et production animale, chasse et services annexes': 'Crop and animal production, hunting and related service activities',
            'Cultures non permanentes': 'Growing of non-perennial crops',
            "Culture de céréales (à l'exception du riz), de légumineuses et de graines oléagineuses": 'Growing of cereals (except rice), leguminous crops and oil seeds',
        },
        'es': {
            'AGRICULTURE, SYLVICULTURE ET PÊCHE': 'AGRICULTURA, SILVICULTURA Y PESCA',
            'Culture et production animale, chasse et services annexes': 'Agricultura, ganadería, caza y servicios relacionados',
            'Cultures non permanentes': 'Cultivos no permanentes',
            "Culture de céréales (à l'exception du riz), de légumineuses et de graines oléagineuses": 'Cultivo de cereales (excepto arroz), legumbres y semillas oleaginosas',
        },
        'de': {
            'AGRICULTURE, SYLVICULTURE ET PÊCHE': 'LANDWIRTSCHAFT, FORSTWIRTSCHAFT UND FISCHEREI',
            'Culture et production animale, chasse et services annexes': 'Landwirtschaft, Jagd und damit verbundene Tätigkeiten',
            'Cultures non permanentes': 'Anbau einjähriger Pflanzen',
            "Culture de céréales (à l'exception du riz), de légumineuses et de graines oléagineuses": 'Anbau von Getreide (ohne Reis), Hülsenfrüchten und Ölsaaten',
        },
        'it': {
            'AGRICULTURE, SYLVICULTURE ET PÊCHE': 'AGRICOLTURA, SILVICOLTURA E PESCA',
            'Culture et production animale, chasse et services annexes': 'Coltivazioni agricole e produzione di prodotti animali, caccia e servizi connessi',
            'Cultures non permanentes': 'Coltivazioni agricole non permanenti',
            "Culture de céréales (à l'exception du riz), de légumineuses et de graines oléagineuses": 'Coltivazione di cereali (escluso il riso), leguminose da granella e semi oleosi',
        }
    }
    
    # Si traduction existe dans le dictionnaire
    if target_lang in translations and text in translations[target_lang]:
        return translations[target_lang][text]
    
    # Sinon, retourner texte avec préfixe de langue pour identifier
    return f"[{target_lang.upper()}] {text}"

def generate_translated_seeds():
    """
    Génère un nouveau fichier de traductions avec les vraies traductions
    """
    
    input_file = Path("nomenclatures_hierarchical/nomenclatures_hierarchical_complete.json")
    output_dir = Path("Lyxal_Solution/dataset/fr/buisness/datatable")
    output_file = output_dir / "business_activity_code_i18n_translations_FULL.surql"
    
    print("=" * 100)
    print("GÉNÉRATION DES TRADUCTIONS COMPLÈTES POUR business_activity_code")
    print("=" * 100)
    print()
    
    # Vérifier si on a une clé API
    use_real_api = DEEPL_API_KEY != "VOTRE_CLE_API_DEEPL"
    
    if use_real_api:
        print("✅ Mode: TRADUCTION RÉELLE avec DeepL API")
        print("   (Coût estimé: ~€20-50 selon volume)")
        print()
        try:
            import deepl
            translator = deepl.Translator(DEEPL_API_KEY)
            print("✅ Connexion DeepL OK")
        except ImportError:
            print("❌ Installez la bibliothèque: pip install deepl")
            return
        except Exception as e:
            print(f"❌ Erreur connexion DeepL: {e}")
            return
    else:
        print("⚠️  Mode: TRADUCTION SIMULÉE (pour test)")
        print("   → Configurez DEEPL_API_KEY pour les vraies traductions")
        print("   → Obtenez une clé gratuite sur: https://www.deepl.com/pro-api")
        print()
    
    # Charger les codes
    print(f"📁 Lecture: {input_file}")
    with open(input_file, 'r', encoding='utf-8') as f:
        codes = json.load(f)
    
    print(f"✅ {len(codes):,} codes chargés")
    print()
    
    # Créer un cache de traductions pour éviter les doublons
    translation_cache = {}
    
    print("📝 Génération du fichier avec traductions...")
    print()
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- " + "=" * 97 + "\n")
        f.write("-- I18N TRANSLATIONS: business_activity_code (TRADUCTIONS COMPLÈTES)\n")
        f.write(f"-- Total: {len(codes):,} codes × 3 libellés × 5 langues = {len(codes) * 3 * 5:,} traductions\n")
        f.write("-- Générées avec: DeepL API (traduction professionnelle)\n" if use_real_api else "-- Mode SIMULATION (remplacer par vraies traductions)\n")
        f.write("-- " + "=" * 97 + "\n\n")
        
        total_translations = 0
        errors = 0
        
        for i, code_data in enumerate(codes):
            if (i + 1) % 100 == 0:
                print(f"   ... {i+1:,} / {len(codes):,} codes traités ({total_translations:,} traductions)")
            
            nomenclature = code_data['nomenclature'].lower()
            code = code_data['code'].replace('.', '_').replace(' ', '_').replace('-', '_').lower()
            record_id = f"{nomenclature}_{code}"
            
            # Traiter les 3 types de libellés
            libelles = [
                ('long', code_data.get('libelle_long', '')),
                ('moyen', code_data.get('libelle_moyen', '')),
                ('court', code_data.get('libelle_court', ''))
            ]
            
            for libelle_type, libelle_fr in libelles:
                if not libelle_fr:
                    continue
                
                key_name = f"i18n_activity_code_{record_id}_{libelle_type}"
                
                # Français (original)
                f.write(f"RELATE i18n_key:{key_name}->i18n_translation->i18n_language:fr\n")
                f.write(f"    SET text = '{escape_string(libelle_fr)}';\n\n")
                total_translations += 1
                
                # Autres langues
                for target_lang in TARGET_LANGUAGES:
                    # Vérifier le cache
                    cache_key = f"{libelle_fr}::{target_lang}"
                    
                    if cache_key in translation_cache:
                        translated_text = translation_cache[cache_key]
                    else:
                        # Traduire
                        if use_real_api:
                            translated_text = translate_with_deepl(libelle_fr, target_lang, DEEPL_API_KEY)
                            if translated_text is None:
                                translated_text = libelle_fr  # Fallback sur français
                                errors += 1
                            time.sleep(0.1)  # Éviter le rate limiting
                        else:
                            translated_text = translate_with_mock(libelle_fr, target_lang)
                        
                        # Mettre en cache
                        translation_cache[cache_key] = translated_text
                    
                    f.write(f"RELATE i18n_key:{key_name}->i18n_translation->i18n_language:{target_lang}\n")
                    f.write(f"    SET text = '{escape_string(translated_text)}';\n\n")
                    total_translations += 1
    
    print()
    print("=" * 100)
    print("✅ GÉNÉRATION TERMINÉE")
    print("=" * 100)
    print()
    print(f"📁 Fichier généré: {output_file}")
    print(f"📊 Total de traductions: {total_translations:,}")
    print(f"📊 Traductions uniques: {len(translation_cache):,}")
    if errors > 0:
        print(f"⚠️  Erreurs de traduction: {errors}")
    print()
    
    if not use_real_api:
        print("⚠️  IMPORTANT:")
        print("   Ce fichier contient des traductions SIMULÉES")
        print("   Pour obtenir les vraies traductions:")
        print("   1. Obtenez une clé API DeepL: https://www.deepl.com/pro-api")
        print("   2. Installez: pip install deepl")
        print("   3. Configurez DEEPL_API_KEY dans ce script")
        print("   4. Relancez le script")
        print()
    
    print("=" * 100)

if __name__ == "__main__":
    generate_translated_seeds()

