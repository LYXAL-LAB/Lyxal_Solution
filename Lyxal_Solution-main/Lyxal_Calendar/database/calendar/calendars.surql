-- ============================================================================
-- Fichier : calendar/calendars.surql
-- Module : calendar
-- TABLE : calendars
-- Description : Table des calendriers. Contient les informations de base sur les calendriers.
-- Cette table sera unique par utilisateur, dans son namespace dans le database main
-- Une réflexion sera à faire sur le fait que l'on regroupe une entité par Namespace (user,saas,etc.)
-- On devra décider si l'utilisateur à un calendrier pour toute ses activité et si on pointe vers
-- les workspace qu'il détient ou si un workspace détient un calendrier quand le module Lyxal_Calendar sera intégré à un workspace
-- Réflexion de base un seul calendrier par Namespace
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS calendars
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Miroir de la table oc_calendars de Nextcloud. Contient les informations de base sur les calendriers.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON calendars 
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du calendrier.';

    DEFINE FIELD IF NOT EXISTS identity.name ON calendars
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Nom technique du calendrier (ex: "calendar-123")';

    DEFINE FIELD IF NOT EXISTS identity.code ON calendars 
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code technique unique au format UPPER_SNAKE_CASE (ex: CALENDAR_123)';

    DEFINE FIELD IF NOT EXISTS identity.slug ON calendars 
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-_]+$')
        COMMENT 'Slug URL-friendly en lowercase-kebab-case (ex: "calendar-123")';

    DEFINE FIELD IF NOT EXISTS identity.displayname ON calendars 
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Nom affiché multilingue du calendrier (ex: "Travail", "Personnel").';
    
    DEFINE FIELD IF NOT EXISTS identity.description ON calendars 
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Description textuelle du calendrier (ex: "Calendrier de travail", "Calendrier personnel").';

-- ============================================================================
-- BLOC METADATA : Métadonnées du calendrier
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON calendars
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées du calendrier.';

    -- ============================================================================
    -- BLOC METADATA.STATUS : Statut du calendrier
    -- ============================================================================

    DEFINE FIELD IF NOT EXISTS metadata.status ON calendars
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc statut : statut du calendrier.';

        DEFINE FIELD IF NOT EXISTS metadata.status.is_active ON calendars
            TYPE bool
            DEFAULT true
            COMMENT 'Indique si le calendrier est actif.';

        DEFINE FIELD IF NOT EXISTS metadata.status.synctoken ON calendars
            TYPE int
            DEFAULT 1
            COMMENT 'Jeton de synchronisation pour les clients CalDAV, incrémenté à chaque modification.';

        DEFINE FIELD IF NOT EXISTS metadata.status.deleted_at ON calendars
            TYPE option<datetime>
            COMMENT 'Timestamp de suppression (soft delete). Si une valeur est présente, le calendrier est dans la corbeille.';
 
    -- ============================================================================
    -- BLOC METADATA.TIMESTAMP : Timestamps de création et modification
    -- ============================================================================

    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON calendars
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON calendars
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création du calendrier.';

            DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON calendars
                TYPE datetime
                READONLY
                DEFAULT ALWAYS time::now()
                COMMENT 'Date de dernière modification du calendrier.';

    DEFINE FIELD IF NOT EXISTS metadata.synctoken ON calendars
        TYPE int
        DEFAULT 1
        COMMENT 'Jeton de synchronisation pour les clients CalDAV, incrémenté à chaque modification.';    

-- ============================================================================
-- BLOC CONTENT : Contenu et informations du calendrier
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON calendars
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations du calendrier.';

    DEFINE FIELD IF NOT EXISTS content.calendarcolor ON calendars 
        TYPE string
        COMMENT 'Couleur du calendrier au format hexadécimal. Ex: "#FF5733".';

    DEFINE FIELD IF NOT EXISTS content.timezone ON calendars 
        TYPE string
        COMMENT 'Fuseau horaire du calendrier. Ex: "Europe/Paris".';

    DEFINE FIELD IF NOT EXISTS content.components ON calendars 
        TYPE string
        DEFAULT "VEVENT,VTODO,VJOURNAL"
        COMMENT 'Types de composants autorisés. Ex: "VEVENT,VTODO".';

    DEFINE FIELD IF NOT EXISTS content.transparent ON calendars 
        TYPE bool
        DEFAULT false
        COMMENT 'Si les événements sont transparents (n''affectent pas la disponibilité).';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_calendar_code_unique ON calendars
    FIELDS identity.code UNIQUE
    COMMENT 'Assure que le code technique du calendrier est unique.';

DEFINE INDEX IF NOT EXISTS idx_calendar_slug_unique ON calendars
    FIELDS identity.slug UNIQUE
    COMMENT 'Assure que le slug du calendrier est unique pour les URLs.';