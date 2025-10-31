#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour générer de VRAIES traductions multilingues pour les icônes Lucide
"""

import json
from pathlib import Path
from typing import Dict, List

# Chemins
LUCIDE_ICONS_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\lucide-main\icons")
OUTPUT_DIR = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\studio\reference\icon\icon")

# Dictionnaire de traduction pour les termes courants
TRANSLATIONS = {
    # Termes généraux
    'home': {'fr': 'Accueil', 'en': 'Home', 'it': 'Casa', 'de': 'Startseite', 'es': 'Inicio'},
    'house': {'fr': 'Maison', 'en': 'House', 'it': 'Casa', 'de': 'Haus', 'es': 'Casa'},
    'user': {'fr': 'Utilisateur', 'en': 'User', 'it': 'Utente', 'de': 'Benutzer', 'es': 'Usuario'},
    'settings': {'fr': 'Paramètres', 'en': 'Settings', 'it': 'Impostazioni', 'de': 'Einstellungen', 'es': 'Configuración'},
    'search': {'fr': 'Rechercher', 'en': 'Search', 'it': 'Cerca', 'de': 'Suchen', 'es': 'Buscar'},
    'filter': {'fr': 'Filtrer', 'en': 'Filter', 'it': 'Filtro', 'de': 'Filter', 'es': 'Filtrar'},
    'menu': {'fr': 'Menu', 'en': 'Menu', 'it': 'Menu', 'de': 'Menü', 'es': 'Menú'},
    'close': {'fr': 'Fermer', 'en': 'Close', 'it': 'Chiudi', 'de': 'Schließen', 'es': 'Cerrar'},
    'open': {'fr': 'Ouvrir', 'en': 'Open', 'it': 'Apri', 'de': 'Öffnen', 'es': 'Abrir'},
    'edit': {'fr': 'Modifier', 'en': 'Edit', 'it': 'Modifica', 'de': 'Bearbeiten', 'es': 'Editar'},
    'delete': {'fr': 'Supprimer', 'en': 'Delete', 'it': 'Elimina', 'de': 'Löschen', 'es': 'Eliminar'},
    'add': {'fr': 'Ajouter', 'en': 'Add', 'it': 'Aggiungi', 'de': 'Hinzufügen', 'es': 'Añadir'},
    'save': {'fr': 'Enregistrer', 'en': 'Save', 'it': 'Salva', 'de': 'Speichern', 'es': 'Guardar'},
    'cancel': {'fr': 'Annuler', 'en': 'Cancel', 'it': 'Annulla', 'de': 'Abbrechen', 'es': 'Cancelar'},
    'check': {'fr': 'Valider', 'en': 'Check', 'it': 'Verifica', 'de': 'Prüfen', 'es': 'Verificar'},
    'info': {'fr': 'Information', 'en': 'Info', 'it': 'Info', 'de': 'Info', 'es': 'Información'},
    'warning': {'fr': 'Avertissement', 'en': 'Warning', 'it': 'Avviso', 'de': 'Warnung', 'es': 'Advertencia'},
    'error': {'fr': 'Erreur', 'en': 'Error', 'it': 'Errore', 'de': 'Fehler', 'es': 'Error'},
    'success': {'fr': 'Succès', 'en': 'Success', 'it': 'Successo', 'de': 'Erfolg', 'es': 'Éxito'},
    'download': {'fr': 'Télécharger', 'en': 'Download', 'it': 'Scarica', 'de': 'Herunterladen', 'es': 'Descargar'},
    'upload': {'fr': 'Téléverser', 'en': 'Upload', 'it': 'Carica', 'de': 'Hochladen', 'es': 'Subir'},
    'refresh': {'fr': 'Actualiser', 'en': 'Refresh', 'it': 'Aggiorna', 'de': 'Aktualisieren', 'es': 'Actualizar'},
    'help': {'fr': 'Aide', 'en': 'Help', 'it': 'Aiuto', 'de': 'Hilfe', 'es': 'Ayuda'},
    'notification': {'fr': 'Notification', 'en': 'Notification', 'it': 'Notifica', 'de': 'Benachrichtigung', 'es': 'Notificación'},
    
    # Directions
    'arrow': {'fr': 'Flèche', 'en': 'Arrow', 'it': 'Freccia', 'de': 'Pfeil', 'es': 'Flecha'},
    'left': {'fr': 'Gauche', 'en': 'Left', 'it': 'Sinistra', 'de': 'Links', 'es': 'Izquierda'},
    'right': {'fr': 'Droite', 'en': 'Right', 'it': 'Destra', 'de': 'Rechts', 'es': 'Derecha'},
    'up': {'fr': 'Haut', 'en': 'Up', 'it': 'Su', 'de': 'Oben', 'es': 'Arriba'},
    'down': {'fr': 'Bas', 'en': 'Down', 'it': 'Giù', 'de': 'Unten', 'es': 'Abajo'},
    
    # Actions
    'copy': {'fr': 'Copier', 'en': 'Copy', 'it': 'Copia', 'de': 'Kopieren', 'es': 'Copiar'},
    'paste': {'fr': 'Coller', 'en': 'Paste', 'it': 'Incolla', 'de': 'Einfügen', 'es': 'Pegar'},
    'cut': {'fr': 'Couper', 'en': 'Cut', 'it': 'Taglia', 'de': 'Ausschneiden', 'es': 'Cortar'},
    'print': {'fr': 'Imprimer', 'en': 'Print', 'it': 'Stampa', 'de': 'Drucken', 'es': 'Imprimir'},
    'share': {'fr': 'Partager', 'en': 'Share', 'it': 'Condividi', 'de': 'Teilen', 'es': 'Compartir'},
    'send': {'fr': 'Envoyer', 'en': 'Send', 'it': 'Invia', 'de': 'Senden', 'es': 'Enviar'},
    
    # Objets
    'file': {'fr': 'Fichier', 'en': 'File', 'it': 'File', 'de': 'Datei', 'es': 'Archivo'},
    'folder': {'fr': 'Dossier', 'en': 'Folder', 'it': 'Cartella', 'de': 'Ordner', 'es': 'Carpeta'},
    'image': {'fr': 'Image', 'en': 'Image', 'it': 'Immagine', 'de': 'Bild', 'es': 'Imagen'},
    'video': {'fr': 'Vidéo', 'en': 'Video', 'it': 'Video', 'de': 'Video', 'es': 'Vídeo'},
    'audio': {'fr': 'Audio', 'en': 'Audio', 'it': 'Audio', 'de': 'Audio', 'es': 'Audio'},
    'document': {'fr': 'Document', 'en': 'Document', 'it': 'Documento', 'de': 'Dokument', 'es': 'Documento'},
    
    # États
    'active': {'fr': 'Actif', 'en': 'Active', 'it': 'Attivo', 'de': 'Aktiv', 'es': 'Activo'},
    'inactive': {'fr': 'Inactif', 'en': 'Inactive', 'it': 'Inattivo', 'de': 'Inaktiv', 'es': 'Inactivo'},
    'online': {'fr': 'En ligne', 'en': 'Online', 'it': 'Online', 'de': 'Online', 'es': 'En línea'},
    'offline': {'fr': 'Hors ligne', 'en': 'Offline', 'it': 'Offline', 'de': 'Offline', 'es': 'Fuera de línea'},
}

def slugify(text: str) -> str:
    """Convertir en slug"""
    return text.lower().replace(' ', '_').replace('-', '_').replace('&', 'and')

def capitalize_words(text: str) -> str:
    """Capitaliser chaque mot"""
    return ' '.join(word.capitalize() for word in text.replace('-', ' ').replace('_', ' ').split())

def translate_icon_name(icon_name: str, language: str, tags: List[str]) -> str:
    """
    Traduire intelligemment le nom d'une icône
    """
    # Nettoyer le nom
    name_parts = icon_name.replace('-', ' ').replace('_', ' ').lower().split()
    
    # Essayer de traduire chaque partie
    translated_parts = []
    for part in name_parts:
        if part in TRANSLATIONS:
            translated_parts.append(TRANSLATIONS[part][language])
        else:
            # Garder le terme anglais capitalisé si pas de traduction
            translated_parts.append(part.capitalize())
    
    # Joindre les parties
    translation = ' '.join(translated_parts)
    
    # Si aucune traduction trouvée, utiliser le nom capitalisé
    if translation == capitalize_words(icon_name):
        # Vérifier si un tag est traduisible
        for tag in tags:
            tag_clean = tag.lower().replace('-', ' ').replace('_', ' ')
            for word in tag_clean.split():
                if word in TRANSLATIONS:
                    # Utiliser la traduction du tag
                    return TRANSLATIONS[word][language]
    
    return translation

def extract_icons() -> List[Dict]:
    """Extraire toutes les icônes avec leurs tags"""
    icons = []
    
    print(f"🔍 Scan de {LUCIDE_ICONS_DIR}...")
    icon_files = sorted(LUCIDE_ICONS_DIR.glob('*.json'))
    print(f"   Trouvé {len(icon_files)} fichiers d'icônes")
    
    for icon_file in icon_files:
        icon_name = icon_file.stem
        
        try:
            with open(icon_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            icon_info = {
                'name': icon_name,
                'value': slugify(icon_name),
                'tags': data.get('tags', [])
            }
            
            icons.append(icon_info)
            
        except Exception as e:
            print(f"⚠️  Erreur lecture {icon_name}: {e}")
    
    return icons

def generate_translations(icons: List[Dict]) -> str:
    """Générer le fichier de traductions avec de VRAIES traductions"""
    output = []
    output.append("-- =============================================================================")
    output.append("-- SEEDS: i18n_translation for icon (Lucide - VRAIES TRADUCTIONS)")
    output.append("-- =============================================================================")
    output.append("-- Traductions intelligentes pour toutes les icônes Lucide")
    output.append("-- Langues: FR, EN, IT, DE, ES")
    output.append("-- Ordre de déploiement : Après icon_i18n_key_seeds_lucide_all.surql")
    output.append("-- =============================================================================")
    output.append("")
    
    total = len(icons)
    
    for idx, icon in enumerate(icons, 1):
        if idx % 100 == 0:
            print(f"   Progression: {idx}/{total} icônes...")
        
        value = icon['value']
        name = icon['name']
        tags = icon['tags']
        
        output.append(f"-- {idx}. {name}")
        
        for lang in ['fr', 'en', 'it', 'de', 'es']:
            # Traduire le nom (technique)
            name_translation = translate_icon_name(name, lang, tags)
            
            # Traduire le label (court, plus user-friendly)
            label_translation = translate_icon_name(name, lang, tags)
            
            # Traduction du name
            output.append(f"RELATE i18n_key:icon_{value}_name->translation->language:{lang}")
            output.append(f"  SET text = '{name_translation}';")
            output.append("")
            
            # Traduction du label
            output.append(f"RELATE i18n_key:icon_{value}_label->translation->language:{lang}")
            output.append(f"  SET text = '{label_translation}';")
            output.append("")
    
    return "\n".join(output)

def main():
    """Fonction principale"""
    print("🌐 Génération des VRAIES traductions pour les icônes Lucide...")
    print()
    print(f"📚 Dictionnaire de traduction : {len(TRANSLATIONS)} termes")
    print()
    
    # Extraire les icônes
    icons = extract_icons()
    print(f"✅ {len(icons)} icônes trouvées")
    
    # Générer les traductions
    print("\n📝 Génération des traductions intelligentes...")
    print(f"   Cela va créer {len(icons) * 2 * 5} traductions (icônes × 2 × 5 langues)")
    
    translations = generate_translations(icons)
    
    # Écrire le fichier
    output_file = OUTPUT_DIR / "icon_i18n_translation_seeds_lucide_all_REAL.surql"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(translations)
    
    print(f"\n✅ Fichier créé : {output_file.name}")
    print(f"\n📊 Statistiques :")
    print(f"   - {len(icons)} icônes")
    print(f"   - {len(icons) * 2} clés i18n (name + label)")
    print(f"   - 5 langues (FR, EN, IT, DE, ES)")
    print(f"   - {len(icons) * 2 * 5} traductions totales")
    print(f"   - {len(TRANSLATIONS)} termes traduits intelligemment")
    print()
    print("✅ Génération terminée !")
    print()
    print("💡 Note : Les icônes sans traduction spécifique gardent leur nom anglais capitalisé.")

if __name__ == '__main__':
    main()

