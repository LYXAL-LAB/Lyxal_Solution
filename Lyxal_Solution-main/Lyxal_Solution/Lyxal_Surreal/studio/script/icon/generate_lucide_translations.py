#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour générer les traductions des catégories Lucide extraites
"""

import json
from pathlib import Path
from typing import Dict

# Chemins
LUCIDE_CATEGORIES_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\categories")
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\reference\icon\icon_category")

# Traductions manuelles des catégories
TRANSLATIONS = {
    'accessibility': {
        'fr': {'name': 'Accessibilité', 'desc': 'Icônes pour l\'accessibilité et l\'inclusion'},
        'en': {'name': 'Accessibility', 'desc': 'Icons for accessibility and inclusion'},
        'it': {'name': 'Accessibilità', 'desc': 'Icone per accessibilità e inclusione'},
        'de': {'name': 'Barrierefreiheit', 'desc': 'Icons für Barrierefreiheit und Inklusion'},
        'es': {'name': 'Accesibilidad', 'desc': 'Iconos para accesibilidad e inclusión'}
    },
    'account': {
        'fr': {'name': 'Compte', 'desc': 'Icônes de compte utilisateur et profil'},
        'en': {'name': 'Account', 'desc': 'User account and profile icons'},
        'it': {'name': 'Account', 'desc': 'Icone per account utente e profilo'},
        'de': {'name': 'Konto', 'desc': 'Benutzerkonto- und Profil-Icons'},
        'es': {'name': 'Cuenta', 'desc': 'Iconos de cuenta de usuario y perfil'}
    },
    'animals': {
        'fr': {'name': 'Animaux', 'desc': 'Icônes d\'animaux et faune'},
        'en': {'name': 'Animals', 'desc': 'Animal and wildlife icons'},
        'it': {'name': 'Animali', 'desc': 'Icone di animali e fauna'},
        'de': {'name': 'Tiere', 'desc': 'Tier- und Wildlife-Icons'},
        'es': {'name': 'Animales', 'desc': 'Iconos de animales y fauna'}
    },
    'arrows': {
        'fr': {'name': 'Flèches', 'desc': 'Icônes de flèches et directions'},
        'en': {'name': 'Arrows', 'desc': 'Arrow and direction icons'},
        'it': {'name': 'Frecce', 'desc': 'Icone di frecce e direzioni'},
        'de': {'name': 'Pfeile', 'desc': 'Pfeil- und Richtungs-Icons'},
        'es': {'name': 'Flechas', 'desc': 'Iconos de flechas y direcciones'}
    },
    'brands': {
        'fr': {'name': 'Marques', 'desc': 'Logos et icônes de marques'},
        'en': {'name': 'Brands', 'desc': 'Brand logos and icons'},
        'it': {'name': 'Marchi', 'desc': 'Loghi e icone di marchi'},
        'de': {'name': 'Marken', 'desc': 'Markenlogos und -Icons'},
        'es': {'name': 'Marcas', 'desc': 'Logotipos e iconos de marcas'}
    },
    'buildings': {
        'fr': {'name': 'Bâtiments', 'desc': 'Icônes de bâtiments et structures'},
        'en': {'name': 'Buildings', 'desc': 'Building and structure icons'},
        'it': {'name': 'Edifici', 'desc': 'Icone di edifici e strutture'},
        'de': {'name': 'Gebäude', 'desc': 'Gebäude- und Struktur-Icons'},
        'es': {'name': 'Edificios', 'desc': 'Iconos de edificios y estructuras'}
    },
    'charts': {
        'fr': {'name': 'Graphiques', 'desc': 'Icônes de graphiques et diagrammes'},
        'en': {'name': 'Charts', 'desc': 'Chart and diagram icons'},
        'it': {'name': 'Grafici', 'desc': 'Icone di grafici e diagrammi'},
        'de': {'name': 'Diagramme', 'desc': 'Diagramm- und Chart-Icons'},
        'es': {'name': 'Gráficos', 'desc': 'Iconos de gráficos y diagramas'}
    },
    'communication': {
        'fr': {'name': 'Communication', 'desc': 'Icônes de communication et messagerie'},
        'en': {'name': 'Communication', 'desc': 'Communication and messaging icons'},
        'it': {'name': 'Comunicazione', 'desc': 'Icone di comunicazione e messaggistica'},
        'de': {'name': 'Kommunikation', 'desc': 'Kommunikations- und Messaging-Icons'},
        'es': {'name': 'Comunicación', 'desc': 'Iconos de comunicación y mensajería'}
    },
    'connectivity': {
        'fr': {'name': 'Connectivité', 'desc': 'Icônes de connexion et réseau'},
        'en': {'name': 'Connectivity', 'desc': 'Connection and network icons'},
        'it': {'name': 'Connettività', 'desc': 'Icone di connessione e rete'},
        'de': {'name': 'Konnektivität', 'desc': 'Verbindungs- und Netzwerk-Icons'},
        'es': {'name': 'Conectividad', 'desc': 'Iconos de conexión y red'}
    },
    'cursors': {
        'fr': {'name': 'Curseurs', 'desc': 'Icônes de curseurs et pointeurs'},
        'en': {'name': 'Cursors', 'desc': 'Cursor and pointer icons'},
        'it': {'name': 'Cursori', 'desc': 'Icone di cursori e puntatori'},
        'de': {'name': 'Cursor', 'desc': 'Cursor- und Zeiger-Icons'},
        'es': {'name': 'Cursores', 'desc': 'Iconos de cursores y punteros'}
    },
    'design': {
        'fr': {'name': 'Design', 'desc': 'Icônes de design et création'},
        'en': {'name': 'Design', 'desc': 'Design and creation icons'},
        'it': {'name': 'Design', 'desc': 'Icone di design e creazione'},
        'de': {'name': 'Design', 'desc': 'Design- und Kreations-Icons'},
        'es': {'name': 'Diseño', 'desc': 'Iconos de diseño y creación'}
    },
    'development': {
        'fr': {'name': 'Développement', 'desc': 'Icônes de développement et code'},
        'en': {'name': 'Development', 'desc': 'Development and code icons'},
        'it': {'name': 'Sviluppo', 'desc': 'Icone di sviluppo e codice'},
        'de': {'name': 'Entwicklung', 'desc': 'Entwicklungs- und Code-Icons'},
        'es': {'name': 'Desarrollo', 'desc': 'Iconos de desarrollo y código'}
    },
    'devices': {
        'fr': {'name': 'Appareils', 'desc': 'Icônes d\'appareils et périphériques'},
        'en': {'name': 'Devices', 'desc': 'Device and peripheral icons'},
        'it': {'name': 'Dispositivi', 'desc': 'Icone di dispositivi e periferiche'},
        'de': {'name': 'Geräte', 'desc': 'Geräte- und Peripherie-Icons'},
        'es': {'name': 'Dispositivos', 'desc': 'Iconos de dispositivos y periféricos'}
    },
    'emoji': {
        'fr': {'name': 'Emoji', 'desc': 'Icônes d\'émojis et émoticônes'},
        'en': {'name': 'Emoji', 'desc': 'Emoji and emoticon icons'},
        'it': {'name': 'Emoji', 'desc': 'Icone di emoji ed emoticon'},
        'de': {'name': 'Emoji', 'desc': 'Emoji- und Emoticon-Icons'},
        'es': {'name': 'Emoji', 'desc': 'Iconos de emoji y emoticonos'}
    },
    'files': {
        'fr': {'name': 'Fichiers', 'desc': 'Icônes de fichiers et documents'},
        'en': {'name': 'Files', 'desc': 'File and document icons'},
        'it': {'name': 'File', 'desc': 'Icone di file e documenti'},
        'de': {'name': 'Dateien', 'desc': 'Datei- und Dokument-Icons'},
        'es': {'name': 'Archivos', 'desc': 'Iconos de archivos y documentos'}
    },
    'finance': {
        'fr': {'name': 'Finance', 'desc': 'Icônes financières et monétaires'},
        'en': {'name': 'Finance', 'desc': 'Financial and monetary icons'},
        'it': {'name': 'Finanza', 'desc': 'Icone finanziarie e monetarie'},
        'de': {'name': 'Finanzen', 'desc': 'Finanz- und Geld-Icons'},
        'es': {'name': 'Finanzas', 'desc': 'Iconos financieros y monetarios'}
    },
    'food_beverage': {
        'fr': {'name': 'Nourriture et Boissons', 'desc': 'Icônes d\'aliments et boissons'},
        'en': {'name': 'Food & Beverage', 'desc': 'Food and beverage icons'},
        'it': {'name': 'Cibo e Bevande', 'desc': 'Icone di cibo e bevande'},
        'de': {'name': 'Essen & Trinken', 'desc': 'Ess- und Getränke-Icons'},
        'es': {'name': 'Comida y Bebidas', 'desc': 'Iconos de comida y bebidas'}
    },
    'gaming': {
        'fr': {'name': 'Jeux', 'desc': 'Icônes de jeux vidéo et gaming'},
        'en': {'name': 'Gaming', 'desc': 'Video game and gaming icons'},
        'it': {'name': 'Giochi', 'desc': 'Icone di videogiochi e gaming'},
        'de': {'name': 'Gaming', 'desc': 'Videospiel- und Gaming-Icons'},
        'es': {'name': 'Juegos', 'desc': 'Iconos de videojuegos y gaming'}
    },
    'home': {
        'fr': {'name': 'Maison', 'desc': 'Icônes de maison et habitat'},
        'en': {'name': 'Home', 'desc': 'Home and habitat icons'},
        'it': {'name': 'Casa', 'desc': 'Icone di casa e habitat'},
        'de': {'name': 'Zuhause', 'desc': 'Haus- und Wohn-Icons'},
        'es': {'name': 'Hogar', 'desc': 'Iconos de hogar y hábitat'}
    },
    'layout': {
        'fr': {'name': 'Mise en page', 'desc': 'Icônes de disposition et structure'},
        'en': {'name': 'Layout', 'desc': 'Layout and structure icons'},
        'it': {'name': 'Layout', 'desc': 'Icone di layout e struttura'},
        'de': {'name': 'Layout', 'desc': 'Layout- und Struktur-Icons'},
        'es': {'name': 'Diseño', 'desc': 'Iconos de diseño y estructura'}
    },
    'mail': {
        'fr': {'name': 'Courrier', 'desc': 'Icônes d\'email et courrier'},
        'en': {'name': 'Mail', 'desc': 'Email and mail icons'},
        'it': {'name': 'Posta', 'desc': 'Icone di email e posta'},
        'de': {'name': 'Mail', 'desc': 'E-Mail- und Post-Icons'},
        'es': {'name': 'Correo', 'desc': 'Iconos de correo y email'}
    },
    'math': {
        'fr': {'name': 'Mathématiques', 'desc': 'Icônes mathématiques et symboles'},
        'en': {'name': 'Math', 'desc': 'Mathematical and symbol icons'},
        'it': {'name': 'Matematica', 'desc': 'Icone matematiche e simboli'},
        'de': {'name': 'Mathematik', 'desc': 'Mathematik- und Symbol-Icons'},
        'es': {'name': 'Matemáticas', 'desc': 'Iconos matemáticos y símbolos'}
    },
    'medical': {
        'fr': {'name': 'Médical', 'desc': 'Icônes médicales et santé'},
        'en': {'name': 'Medical', 'desc': 'Medical and health icons'},
        'it': {'name': 'Medico', 'desc': 'Icone mediche e sanitarie'},
        'de': {'name': 'Medizinisch', 'desc': 'Medizinische und Gesundheits-Icons'},
        'es': {'name': 'Médico', 'desc': 'Iconos médicos y de salud'}
    },
    'multimedia': {
        'fr': {'name': 'Multimédia', 'desc': 'Icônes audio, vidéo et média'},
        'en': {'name': 'Multimedia', 'desc': 'Audio, video and media icons'},
        'it': {'name': 'Multimedia', 'desc': 'Icone audio, video e media'},
        'de': {'name': 'Multimedia', 'desc': 'Audio-, Video- und Medien-Icons'},
        'es': {'name': 'Multimedia', 'desc': 'Iconos de audio, video y media'}
    },
    'nature': {
        'fr': {'name': 'Nature', 'desc': 'Icônes de nature et environnement'},
        'en': {'name': 'Nature', 'desc': 'Nature and environment icons'},
        'it': {'name': 'Natura', 'desc': 'Icone di natura e ambiente'},
        'de': {'name': 'Natur', 'desc': 'Natur- und Umwelt-Icons'},
        'es': {'name': 'Naturaleza', 'desc': 'Iconos de naturaleza y medio ambiente'}
    },
    'navigation': {
        'fr': {'name': 'Navigation', 'desc': 'Icônes de navigation et déplacement'},
        'en': {'name': 'Navigation', 'desc': 'Navigation and movement icons'},
        'it': {'name': 'Navigazione', 'desc': 'Icone di navigazione e spostamento'},
        'de': {'name': 'Navigation', 'desc': 'Navigations- und Bewegungs-Icons'},
        'es': {'name': 'Navegación', 'desc': 'Iconos de navegación y desplazamiento'}
    },
    'notifications': {
        'fr': {'name': 'Notifications', 'desc': 'Icônes de notifications et alertes'},
        'en': {'name': 'Notifications', 'desc': 'Notification and alert icons'},
        'it': {'name': 'Notifiche', 'desc': 'Icone di notifiche e avvisi'},
        'de': {'name': 'Benachrichtigungen', 'desc': 'Benachrichtigungs- und Alarm-Icons'},
        'es': {'name': 'Notificaciones', 'desc': 'Iconos de notificaciones y alertas'}
    },
    'people': {
        'fr': {'name': 'Personnes', 'desc': 'Icônes de personnes et utilisateurs'},
        'en': {'name': 'People', 'desc': 'People and user icons'},
        'it': {'name': 'Persone', 'desc': 'Icone di persone e utenti'},
        'de': {'name': 'Menschen', 'desc': 'Menschen- und Benutzer-Icons'},
        'es': {'name': 'Personas', 'desc': 'Iconos de personas y usuarios'}
    },
    'photography': {
        'fr': {'name': 'Photographie', 'desc': 'Icônes de photographie et images'},
        'en': {'name': 'Photography', 'desc': 'Photography and image icons'},
        'it': {'name': 'Fotografia', 'desc': 'Icone di fotografia e immagini'},
        'de': {'name': 'Fotografie', 'desc': 'Fotografie- und Bild-Icons'},
        'es': {'name': 'Fotografía', 'desc': 'Iconos de fotografía e imágenes'}
    },
    'science': {
        'fr': {'name': 'Science', 'desc': 'Icônes scientifiques et recherche'},
        'en': {'name': 'Science', 'desc': 'Scientific and research icons'},
        'it': {'name': 'Scienza', 'desc': 'Icone scientifiche e ricerca'},
        'de': {'name': 'Wissenschaft', 'desc': 'Wissenschafts- und Forschungs-Icons'},
        'es': {'name': 'Ciencia', 'desc': 'Iconos científicos y de investigación'}
    },
    'seasons': {
        'fr': {'name': 'Saisons', 'desc': 'Icônes des saisons'},
        'en': {'name': 'Seasons', 'desc': 'Season icons'},
        'it': {'name': 'Stagioni', 'desc': 'Icone delle stagioni'},
        'de': {'name': 'Jahreszeiten', 'desc': 'Jahreszeiten-Icons'},
        'es': {'name': 'Estaciones', 'desc': 'Iconos de las estaciones'}
    },
    'security': {
        'fr': {'name': 'Sécurité', 'desc': 'Icônes de sécurité et protection'},
        'en': {'name': 'Security', 'desc': 'Security and protection icons'},
        'it': {'name': 'Sicurezza', 'desc': 'Icone di sicurezza e protezione'},
        'de': {'name': 'Sicherheit', 'desc': 'Sicherheits- und Schutz-Icons'},
        'es': {'name': 'Seguridad', 'desc': 'Iconos de seguridad y protección'}
    },
    'shapes': {
        'fr': {'name': 'Formes', 'desc': 'Icônes de formes géométriques'},
        'en': {'name': 'Shapes', 'desc': 'Geometric shape icons'},
        'it': {'name': 'Forme', 'desc': 'Icone di forme geometriche'},
        'de': {'name': 'Formen', 'desc': 'Geometrische Form-Icons'},
        'es': {'name': 'Formas', 'desc': 'Iconos de formas geométricas'}
    },
    'shopping': {
        'fr': {'name': 'Shopping', 'desc': 'Icônes d\'achats et commerce'},
        'en': {'name': 'Shopping', 'desc': 'Shopping and commerce icons'},
        'it': {'name': 'Shopping', 'desc': 'Icone di acquisti e commercio'},
        'de': {'name': 'Einkaufen', 'desc': 'Einkaufs- und Handels-Icons'},
        'es': {'name': 'Compras', 'desc': 'Iconos de compras y comercio'}
    },
    'social': {
        'fr': {'name': 'Social', 'desc': 'Icônes de réseaux sociaux'},
        'en': {'name': 'Social', 'desc': 'Social network icons'},
        'it': {'name': 'Social', 'desc': 'Icone di social network'},
        'de': {'name': 'Soziale Medien', 'desc': 'Social-Media-Icons'},
        'es': {'name': 'Social', 'desc': 'Iconos de redes sociales'}
    },
    'sports': {
        'fr': {'name': 'Sports', 'desc': 'Icônes de sports et activités'},
        'en': {'name': 'Sports', 'desc': 'Sports and activity icons'},
        'it': {'name': 'Sport', 'desc': 'Icone di sport e attività'},
        'de': {'name': 'Sport', 'desc': 'Sport- und Aktivitäts-Icons'},
        'es': {'name': 'Deportes', 'desc': 'Iconos de deportes y actividades'}
    },
    'sustainability': {
        'fr': {'name': 'Durabilité', 'desc': 'Icônes de développement durable'},
        'en': {'name': 'Sustainability', 'desc': 'Sustainable development icons'},
        'it': {'name': 'Sostenibilità', 'desc': 'Icone di sviluppo sostenibile'},
        'de': {'name': 'Nachhaltigkeit', 'desc': 'Nachhaltigkeits-Icons'},
        'es': {'name': 'Sostenibilidad', 'desc': 'Iconos de desarrollo sostenible'}
    },
    'text': {
        'fr': {'name': 'Texte', 'desc': 'Icônes de texte et typographie'},
        'en': {'name': 'Text', 'desc': 'Text and typography icons'},
        'it': {'name': 'Testo', 'desc': 'Icone di testo e tipografia'},
        'de': {'name': 'Text', 'desc': 'Text- und Typografie-Icons'},
        'es': {'name': 'Texto', 'desc': 'Iconos de texto y tipografía'}
    },
    'time': {
        'fr': {'name': 'Temps', 'desc': 'Icônes de temps et horloges'},
        'en': {'name': 'Time', 'desc': 'Time and clock icons'},
        'it': {'name': 'Tempo', 'desc': 'Icone di tempo e orologi'},
        'de': {'name': 'Zeit', 'desc': 'Zeit- und Uhr-Icons'},
        'es': {'name': 'Tiempo', 'desc': 'Iconos de tiempo y relojes'}
    },
    'tools': {
        'fr': {'name': 'Outils', 'desc': 'Icônes d\'outils et utilitaires'},
        'en': {'name': 'Tools', 'desc': 'Tool and utility icons'},
        'it': {'name': 'Strumenti', 'desc': 'Icone di strumenti e utilità'},
        'de': {'name': 'Werkzeuge', 'desc': 'Werkzeug- und Utility-Icons'},
        'es': {'name': 'Herramientas', 'desc': 'Iconos de herramientas y utilidades'}
    },
    'transportation': {
        'fr': {'name': 'Transport', 'desc': 'Icônes de transport et véhicules'},
        'en': {'name': 'Transportation', 'desc': 'Transportation and vehicle icons'},
        'it': {'name': 'Trasporti', 'desc': 'Icone di trasporti e veicoli'},
        'de': {'name': 'Transport', 'desc': 'Transport- und Fahrzeug-Icons'},
        'es': {'name': 'Transporte', 'desc': 'Iconos de transporte y vehículos'}
    },
    'travel': {
        'fr': {'name': 'Voyage', 'desc': 'Icônes de voyage et tourisme'},
        'en': {'name': 'Travel', 'desc': 'Travel and tourism icons'},
        'it': {'name': 'Viaggio', 'desc': 'Icone di viaggio e turismo'},
        'de': {'name': 'Reisen', 'desc': 'Reise- und Tourismus-Icons'},
        'es': {'name': 'Viaje', 'desc': 'Iconos de viaje y turismo'}
    },
    'weather': {
        'fr': {'name': 'Météo', 'desc': 'Icônes météorologiques'},
        'en': {'name': 'Weather', 'desc': 'Weather icons'},
        'it': {'name': 'Meteo', 'desc': 'Icone meteorologiche'},
        'de': {'name': 'Wetter', 'desc': 'Wetter-Icons'},
        'es': {'name': 'Clima', 'desc': 'Iconos meteorológicos'}
    }
}

def slugify(text: str) -> str:
    """Convertir en slug"""
    return text.lower().replace(' ', '_').replace('-', '_')

def extract_categories():
    """Extraire les catégories"""
    categories = []
    for category_file in sorted(LUCIDE_CATEGORIES_DIR.glob('*.json')):
        category_slug = category_file.stem
        categories.append(slugify(category_slug))
    return categories

def generate_translations():
    """Générer le fichier de traductions"""
    categories = extract_categories()
    
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: i18n_translation for icon_category (Lucide)")
    output.append("-- =============================================================================")
    output.append("-- Traductions pour les catégories d'icônes extraites de Lucide")
    output.append("-- Langues: FR, EN, IT, DE, ES")
    output.append("-- Ordre de déploiement : Après icon_category_i18n_key_seeds_lucide.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    for idx, cat_slug in enumerate(categories, 1):
        if cat_slug not in TRANSLATIONS:
            print(f"⚠️  Traduction manquante pour : {cat_slug}")
            continue
        
        trans = TRANSLATIONS[cat_slug]
        
        output.append(f"-- =============================================================================")
        output.append(f"-- {idx}. {trans['en']['name'].upper()}")
        output.append(f"-- =============================================================================")
        output.append("")
        
        for lang in ['fr', 'en', 'it', 'de', 'es']:
            output.append(f"-- {lang.upper()}")
            output.append(f"RELATE i18n_key:icon_category_{cat_slug}_name->translation->language:{lang}")
            output.append(f"  SET text = '{trans[lang]['name']}';")
            output.append("")
            output.append(f"RELATE i18n_key:icon_category_{cat_slug}_description->translation->language:{lang}")
            output.append(f"  SET text = '{trans[lang]['desc']}';")
            output.append("")
        
    return "\n".join(output)

def main():
    """Fonction principale"""
    print("🌐 Génération des traductions...")
    translations = generate_translations()
    
    output_file = OUTPUT_DIR / "icon_category_i18n_translation_seeds_lucide.surql"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(translations)
    
    print(f"✅ Fichier créé : {output_file.name}")
    print(f"📊 43 catégories × 5 langues × 2 (name + desc) = 430 traductions")

if __name__ == '__main__':
    main()

