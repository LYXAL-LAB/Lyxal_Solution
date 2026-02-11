-- =============================================================================
-- SEEDS: translation for icon_category
-- =============================================================================
-- Traductions des catégories d'icônes (FR, EN, IT, DE, ES)
-- Ordre de déploiement : Après icon_category_i18n_key_seeds.surql et language seeds
-- Table : translation (RELATION entre i18n_key et language)
-- =============================================================================

-- ============================================================================
-- 1. INTERFACE (UI)
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_interface_name->translation->language:fr
  SET text = 'Interface';

RELATE i18n_key:icon_category_interface_description->translation->language:fr
  SET text = 'Éléments d\'interface utilisateur : boutons, inputs, modales, dialogues, contrôles';

-- Anglais
RELATE i18n_key:icon_category_interface_name->translation->language:en
  SET text = 'Interface';

RELATE i18n_key:icon_category_interface_description->translation->language:en
  SET text = 'User interface elements: buttons, inputs, modals, dialogs, controls';

-- Italien
RELATE i18n_key:icon_category_interface_name->translation->language:it
  SET text = 'Interfaccia';

RELATE i18n_key:icon_category_interface_description->translation->language:it
  SET text = 'Elementi dell\'interfaccia utente: pulsanti, input, modali, dialoghi, controlli';

-- Allemand
RELATE i18n_key:icon_category_interface_name->translation->language:de
  SET text = 'Benutzeroberfläche';

RELATE i18n_key:icon_category_interface_description->translation->language:de
  SET text = 'Benutzeroberflächenelemente: Schaltflächen, Eingaben, Modale, Dialoge, Steuerelemente';

-- Espagnol
RELATE i18n_key:icon_category_interface_name->translation->language:es
  SET text = 'Interfaz';

RELATE i18n_key:icon_category_interface_description->translation->language:es
  SET text = 'Elementos de interfaz de usuario: botones, entradas, modales, diálogos, controles';

-- ============================================================================
-- 2. NAVIGATION
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_navigation_name->translation->language:fr
  SET text = 'Navigation';

RELATE i18n_key:icon_category_navigation_description->translation->language:fr
  SET text = 'Navigation et déplacement : accueil, menu, flèches, chevrons, liens';

-- Anglais
RELATE i18n_key:icon_category_navigation_name->translation->language:en
  SET text = 'Navigation';

RELATE i18n_key:icon_category_navigation_description->translation->language:en
  SET text = 'Navigation and movement: home, menu, arrows, chevrons, links';

-- Italien
RELATE i18n_key:icon_category_navigation_name->translation->language:it
  SET text = 'Navigazione';

RELATE i18n_key:icon_category_navigation_description->translation->language:it
  SET text = 'Navigazione e movimento: home, menu, frecce, chevron, link';

-- Allemand
RELATE i18n_key:icon_category_navigation_name->translation->language:de
  SET text = 'Navigation';

RELATE i18n_key:icon_category_navigation_description->translation->language:de
  SET text = 'Navigation und Bewegung: Startseite, Menü, Pfeile, Chevrons, Links';

-- Espagnol
RELATE i18n_key:icon_category_navigation_name->translation->language:es
  SET text = 'Navegación';

RELATE i18n_key:icon_category_navigation_description->translation->language:es
  SET text = 'Navegación y movimiento: inicio, menú, flechas, chevrones, enlaces';

-- ============================================================================
-- 3. ACTION
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_action_name->translation->language:fr
  SET text = 'Action';

RELATE i18n_key:icon_category_action_description->translation->language:fr
  SET text = 'Actions utilisateur : créer, modifier, supprimer, éditer, interactions';

-- Anglais
RELATE i18n_key:icon_category_action_name->translation->language:en
  SET text = 'Action';

RELATE i18n_key:icon_category_action_description->translation->language:en
  SET text = 'User actions: create, edit, delete, modify, interactions';

-- Italien
RELATE i18n_key:icon_category_action_name->translation->language:it
  SET text = 'Azione';

RELATE i18n_key:icon_category_action_description->translation->language:it
  SET text = 'Azioni utente: creare, modificare, eliminare, modificare, interazioni';

-- Allemand
RELATE i18n_key:icon_category_action_name->translation->language:de
  SET text = 'Aktion';

RELATE i18n_key:icon_category_action_description->translation->language:de
  SET text = 'Benutzeraktionen: erstellen, bearbeiten, löschen, ändern, Interaktionen';

-- Espagnol
RELATE i18n_key:icon_category_action_name->translation->language:es
  SET text = 'Acción';

RELATE i18n_key:icon_category_action_description->translation->language:es
  SET text = 'Acciones de usuario: crear, editar, eliminar, modificar, interacciones';

-- ============================================================================
-- 4. DATA
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_data_name->translation->language:fr
  SET text = 'Données';

RELATE i18n_key:icon_category_data_description->translation->language:fr
  SET text = 'Données et stockage : bases de données, fichiers, dossiers, documents';

-- Anglais
RELATE i18n_key:icon_category_data_name->translation->language:en
  SET text = 'Data';

RELATE i18n_key:icon_category_data_description->translation->language:en
  SET text = 'Data and storage: databases, files, folders, documents';

-- Italien
RELATE i18n_key:icon_category_data_name->translation->language:it
  SET text = 'Dati';

RELATE i18n_key:icon_category_data_description->translation->language:it
  SET text = 'Dati e archiviazione: database, file, cartelle, documenti';

-- Allemand
RELATE i18n_key:icon_category_data_name->translation->language:de
  SET text = 'Daten';

RELATE i18n_key:icon_category_data_description->translation->language:de
  SET text = 'Daten und Speicherung: Datenbanken, Dateien, Ordner, Dokumente';

-- Espagnol
RELATE i18n_key:icon_category_data_name->translation->language:es
  SET text = 'Datos';

RELATE i18n_key:icon_category_data_description->translation->language:es
  SET text = 'Datos y almacenamiento: bases de datos, archivos, carpetas, documentos';

-- ============================================================================
-- 5. COMMUNICATION
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_communication_name->translation->language:fr
  SET text = 'Communication';

RELATE i18n_key:icon_category_communication_description->translation->language:fr
  SET text = 'Communication : email, messages, chat, notifications, téléphone';

-- Anglais
RELATE i18n_key:icon_category_communication_name->translation->language:en
  SET text = 'Communication';

RELATE i18n_key:icon_category_communication_description->translation->language:en
  SET text = 'Communication: email, messages, chat, notifications, phone';

-- Italien
RELATE i18n_key:icon_category_communication_name->translation->language:it
  SET text = 'Comunicazione';

RELATE i18n_key:icon_category_communication_description->translation->language:it
  SET text = 'Comunicazione: email, messaggi, chat, notifiche, telefono';

-- Allemand
RELATE i18n_key:icon_category_communication_name->translation->language:de
  SET text = 'Kommunikation';

RELATE i18n_key:icon_category_communication_description->translation->language:de
  SET text = 'Kommunikation: E-Mail, Nachrichten, Chat, Benachrichtigungen, Telefon';

-- Espagnol
RELATE i18n_key:icon_category_communication_name->translation->language:es
  SET text = 'Comunicación';

RELATE i18n_key:icon_category_communication_description->translation->language:es
  SET text = 'Comunicación: correo electrónico, mensajes, chat, notificaciones, teléfono';

-- ============================================================================
-- 6. USER
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_user_name->translation->language:fr
  SET text = 'Utilisateur';

RELATE i18n_key:icon_category_user_description->translation->language:fr
  SET text = 'Utilisateurs et profils : utilisateurs, groupes, équipes, permissions';

-- Anglais
RELATE i18n_key:icon_category_user_name->translation->language:en
  SET text = 'User';

RELATE i18n_key:icon_category_user_description->translation->language:en
  SET text = 'Users and profiles: users, groups, teams, permissions';

-- Italien
RELATE i18n_key:icon_category_user_name->translation->language:it
  SET text = 'Utente';

RELATE i18n_key:icon_category_user_description->translation->language:it
  SET text = 'Utenti e profili: utenti, gruppi, team, permessi';

-- Allemand
RELATE i18n_key:icon_category_user_name->translation->language:de
  SET text = 'Benutzer';

RELATE i18n_key:icon_category_user_description->translation->language:de
  SET text = 'Benutzer und Profile: Benutzer, Gruppen, Teams, Berechtigungen';

-- Espagnol
RELATE i18n_key:icon_category_user_name->translation->language:es
  SET text = 'Usuario';

RELATE i18n_key:icon_category_user_description->translation->language:es
  SET text = 'Usuarios y perfiles: usuarios, grupos, equipos, permisos';

-- ============================================================================
-- 7. SYSTEM
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_system_name->translation->language:fr
  SET text = 'Système';

RELATE i18n_key:icon_category_system_description->translation->language:fr
  SET text = 'Système et configuration : paramètres, outils, administration, sécurité';

-- Anglais
RELATE i18n_key:icon_category_system_name->translation->language:en
  SET text = 'System';

RELATE i18n_key:icon_category_system_description->translation->language:en
  SET text = 'System and configuration: settings, tools, administration, security';

-- Italien
RELATE i18n_key:icon_category_system_name->translation->language:it
  SET text = 'Sistema';

RELATE i18n_key:icon_category_system_description->translation->language:it
  SET text = 'Sistema e configurazione: impostazioni, strumenti, amministrazione, sicurezza';

-- Allemand
RELATE i18n_key:icon_category_system_name->translation->language:de
  SET text = 'System';

RELATE i18n_key:icon_category_system_description->translation->language:de
  SET text = 'System und Konfiguration: Einstellungen, Tools, Verwaltung, Sicherheit';

-- Espagnol
RELATE i18n_key:icon_category_system_name->translation->language:es
  SET text = 'Sistema';

RELATE i18n_key:icon_category_system_description->translation->language:es
  SET text = 'Sistema y configuración: ajustes, herramientas, administración, seguridad';

-- ============================================================================
-- 8. STATUS
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_status_name->translation->language:fr
  SET text = 'Statut';

RELATE i18n_key:icon_category_status_description->translation->language:fr
  SET text = 'Statuts et indicateurs : succès, erreur, avertissement, information';

-- Anglais
RELATE i18n_key:icon_category_status_name->translation->language:en
  SET text = 'Status';

RELATE i18n_key:icon_category_status_description->translation->language:en
  SET text = 'Status and indicators: success, error, warning, information';

-- Italien
RELATE i18n_key:icon_category_status_name->translation->language:it
  SET text = 'Stato';

RELATE i18n_key:icon_category_status_description->translation->language:it
  SET text = 'Stati e indicatori: successo, errore, avviso, informazione';

-- Allemand
RELATE i18n_key:icon_category_status_name->translation->language:de
  SET text = 'Status';

RELATE i18n_key:icon_category_status_description->translation->language:de
  SET text = 'Status und Indikatoren: Erfolg, Fehler, Warnung, Information';

-- Espagnol
RELATE i18n_key:icon_category_status_name->translation->language:es
  SET text = 'Estado';

RELATE i18n_key:icon_category_status_description->translation->language:es
  SET text = 'Estados e indicadores: éxito, error, advertencia, información';

-- ============================================================================
-- 9. MEDIA
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_media_name->translation->language:fr
  SET text = 'Média';

RELATE i18n_key:icon_category_media_description->translation->language:fr
  SET text = 'Multimédia : images, vidéos, audio, musique, galerie, caméra';

-- Anglais
RELATE i18n_key:icon_category_media_name->translation->language:en
  SET text = 'Media';

RELATE i18n_key:icon_category_media_description->translation->language:en
  SET text = 'Multimedia: images, videos, audio, music, gallery, camera';

-- Italien
RELATE i18n_key:icon_category_media_name->translation->language:it
  SET text = 'Media';

RELATE i18n_key:icon_category_media_description->translation->language:it
  SET text = 'Multimedia: immagini, video, audio, musica, galleria, fotocamera';

-- Allemand
RELATE i18n_key:icon_category_media_name->translation->language:de
  SET text = 'Medien';

RELATE i18n_key:icon_category_media_description->translation->language:de
  SET text = 'Multimedia: Bilder, Videos, Audio, Musik, Galerie, Kamera';

-- Espagnol
RELATE i18n_key:icon_category_media_name->translation->language:es
  SET text = 'Medios';

RELATE i18n_key:icon_category_media_description->translation->language:es
  SET text = 'Multimedia: imágenes, videos, audio, música, galería, cámara';

-- ============================================================================
-- 10. BUSINESS
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_business_name->translation->language:fr
  SET text = 'Business';

RELATE i18n_key:icon_category_business_description->translation->language:fr
  SET text = 'Business et métier : finances, graphiques, statistiques, rapports, commerce';

-- Anglais
RELATE i18n_key:icon_category_business_name->translation->language:en
  SET text = 'Business';

RELATE i18n_key:icon_category_business_description->translation->language:en
  SET text = 'Business: finance, charts, statistics, reports, commerce';

-- Italien
RELATE i18n_key:icon_category_business_name->translation->language:it
  SET text = 'Business';

RELATE i18n_key:icon_category_business_description->translation->language:it
  SET text = 'Business: finanza, grafici, statistiche, report, commercio';

-- Allemand
RELATE i18n_key:icon_category_business_name->translation->language:de
  SET text = 'Geschäft';

RELATE i18n_key:icon_category_business_description->translation->language:de
  SET text = 'Geschäft: Finanzen, Diagramme, Statistiken, Berichte, Handel';

-- Espagnol
RELATE i18n_key:icon_category_business_name->translation->language:es
  SET text = 'Negocios';

RELATE i18n_key:icon_category_business_description->translation->language:es
  SET text = 'Negocios: finanzas, gráficos, estadísticas, informes, comercio';

-- ============================================================================
-- 11. DEVELOPMENT
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_development_name->translation->language:fr
  SET text = 'Développement';

RELATE i18n_key:icon_category_development_description->translation->language:fr
  SET text = 'Développement et technique : code, terminal, git, API, debug';

-- Anglais
RELATE i18n_key:icon_category_development_name->translation->language:en
  SET text = 'Development';

RELATE i18n_key:icon_category_development_description->translation->language:en
  SET text = 'Development and technical: code, terminal, git, API, debug';

-- Italien
RELATE i18n_key:icon_category_development_name->translation->language:it
  SET text = 'Sviluppo';

RELATE i18n_key:icon_category_development_description->translation->language:it
  SET text = 'Sviluppo e tecnico: codice, terminale, git, API, debug';

-- Allemand
RELATE i18n_key:icon_category_development_name->translation->language:de
  SET text = 'Entwicklung';

RELATE i18n_key:icon_category_development_description->translation->language:de
  SET text = 'Entwicklung und Technik: Code, Terminal, Git, API, Debug';

-- Espagnol
RELATE i18n_key:icon_category_development_name->translation->language:es
  SET text = 'Desarrollo';

RELATE i18n_key:icon_category_development_description->translation->language:es
  SET text = 'Desarrollo y técnico: código, terminal, git, API, depuración';

-- ============================================================================
-- 12. BRAND
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_brand_name->translation->language:fr
  SET text = 'Marque';

RELATE i18n_key:icon_category_brand_description->translation->language:fr
  SET text = 'Marques et identité : logos, marques, réseaux sociaux, entreprises';

-- Anglais
RELATE i18n_key:icon_category_brand_name->translation->language:en
  SET text = 'Brand';

RELATE i18n_key:icon_category_brand_description->translation->language:en
  SET text = 'Brands and identity: logos, brands, social media, companies';

-- Italien
RELATE i18n_key:icon_category_brand_name->translation->language:it
  SET text = 'Marca';

RELATE i18n_key:icon_category_brand_description->translation->language:it
  SET text = 'Marchi e identità: loghi, marchi, social media, aziende';

-- Allemand
RELATE i18n_key:icon_category_brand_name->translation->language:de
  SET text = 'Marke';

RELATE i18n_key:icon_category_brand_description->translation->language:de
  SET text = 'Marken und Identität: Logos, Marken, soziale Medien, Unternehmen';

-- Espagnol
RELATE i18n_key:icon_category_brand_name->translation->language:es
  SET text = 'Marca';

RELATE i18n_key:icon_category_brand_description->translation->language:es
  SET text = 'Marcas e identidad: logos, marcas, redes sociales, empresas';

-- ============================================================================
-- 13. OTHER
-- ============================================================================

-- Français
RELATE i18n_key:icon_category_other_name->translation->language:fr
  SET text = 'Autre';

RELATE i18n_key:icon_category_other_description->translation->language:fr
  SET text = 'Autres icônes non classifiées dans une catégorie spécifique';

-- Anglais
RELATE i18n_key:icon_category_other_name->translation->language:en
  SET text = 'Other';

RELATE i18n_key:icon_category_other_description->translation->language:en
  SET text = 'Other icons not classified in a specific category';

-- Italien
RELATE i18n_key:icon_category_other_name->translation->language:it
  SET text = 'Altro';

RELATE i18n_key:icon_category_other_description->translation->language:it
  SET text = 'Altre icone non classificate in una categoria specifica';

-- Allemand
RELATE i18n_key:icon_category_other_name->translation->language:de
  SET text = 'Sonstiges';

RELATE i18n_key:icon_category_other_description->translation->language:de
  SET text = 'Andere Symbole, die nicht in eine bestimmte Kategorie eingeordnet sind';

-- Espagnol
RELATE i18n_key:icon_category_other_name->translation->language:es
  SET text = 'Otro';

RELATE i18n_key:icon_category_other_description->translation->language:es
  SET text = 'Otros iconos no clasificados en una categoría específica';
