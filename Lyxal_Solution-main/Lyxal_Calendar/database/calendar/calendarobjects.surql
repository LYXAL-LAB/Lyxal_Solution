-- ============================================================================
-- Fichier : calendar/calendarobjects.surql
-- Module : calendar
-- TABLE : calendarobjects
-- Description : Table des objets de calendrier (événements, tâches).
--               Chaque objet est lié à un calendrier parent.
-- Auteur : Yaniss Dubreucq & Gemini
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS calendarobjects
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Table des objets de calendrier. Contient les données des événements/tâches.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'objet
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON calendarobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de l\'objet de calendrier.';

    DEFINE FIELD IF NOT EXISTS identity.uri ON calendarobjects
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'URI unique de l\'objet à l\'intérieur d\'un calendrier. Ex: "mon-evenement.ics".';
    
    DEFINE FIELD IF NOT EXISTS identity.uid ON calendarobjects
        TYPE string
        ASSERT $value != NONE
        COMMENT 'UID iCalendar, identifiant unique global de l\'événement.';

-- ============================================================================
-- BLOC METADATA : Métadonnées de l'objet
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON calendarobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées de l\'objet.';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON calendarobjects
        TYPE uuid
        READONLY
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'Entity Tag pour la gestion du cache HTTP (ETag).';

    DEFINE FIELD IF NOT EXISTS metadata.size ON calendarobjects
        TYPE int
        COMMENT 'Taille de l\'objet calendardata en octets.';

    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON calendarobjects
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON calendarobjects
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création de l\'objet.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON calendarobjects
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT 'Date de dernière modification de l\'objet.';
            
        DEFINE FIELD IF NOT EXISTS metadata.timestamp.lastmodified ON calendarobjects
            TYPE int
            COMMENT 'Timestamp (entier) de la dernière modification pour compatibilité CalDAV.';

-- ============================================================================
-- BLOC CONTENT : Données principales de l'objet
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON calendarobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations de l''objet de calendrier.';
    
    DEFINE FIELD IF NOT EXISTS content.calendardata ON calendarobjects
        TYPE string
        COMMENT 'Contenu complet de l\'objet au format iCalendar (RFC 5545).';
        
    DEFINE FIELD IF NOT EXISTS content.componenttype ON calendarobjects
        TYPE string
        COMMENT 'Type de composant principal. Ex: "VEVENT", "VTODO".';
        
    DEFINE FIELD IF NOT EXISTS content.firstoccurence ON calendarobjects
        TYPE int
        COMMENT 'Timestamp de la première occurrence (pour les événements récurrents).';
        
    DEFINE FIELD IF NOT EXISTS content.lastoccurence ON calendarobjects
        TYPE int
        COMMENT 'Timestamp de la dernière occurrence (pour les événements récurrents).';
        
    DEFINE FIELD IF NOT EXISTS content.classification ON calendarobjects
        TYPE int
        DEFAULT 0
        COMMENT 'Classification de la confidentialité : 0=PUBLIC, 1=PRIVATE, 2=CONFIDENTIAL.';

-- ============================================================================
-- RELATIONS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS calendar ON calendarobjects 
    TYPE record<calendars>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au calendrier parent.';

-- ============================================================================
-- INDEX
-- ============================================================================
  
DEFINE INDEX IF NOT EXISTS calobjects_calendar_uri_unique ON calendarobjects
    FIELDS calendar.identity.code, identity.uri UNIQUE
    COMMENT 'Assure que l''URI de l''objet est unique pour un calendrier donné.';

DEFINE INDEX IF NOT EXISTS calobjects_uid ON calendarobjects
    FIELDS identity.uid
    COMMENT 'Index sur l\'UID iCal pour des recherches rapides.';
