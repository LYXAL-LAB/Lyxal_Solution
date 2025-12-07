-- ============================================================================
-- Fichier : calendar/calendarsubscriptions.surql
-- Module : calendar
-- TABLE : calendarsubscriptions
-- Description : Gère les abonnements personnels de l'utilisateur à des calendriers externes.
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
--
-- REFLEXION D'ARCHITECTURE :
-- Le champ 'principaluri' (relation vers un utilisateur) a été retiré car chaque 
-- utilisateur opère dans son propre namespace/DB, rendant ce champ redondant.
-- Une relation vers un 'workspace' pourra être ajoutée ici plus tard si un abonnement
-- doit être partagé au niveau d'un espace de travail.
-- ============================================================================

DEFINE TABLE IF NOT EXISTS calendarsubscriptions
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Gère les abonnements à des calendriers iCalendar externes (webcal).'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'abonnement
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON calendarsubscriptions
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de l\'abonnement.';

    DEFINE FIELD IF NOT EXISTS identity.uri ON calendarsubscriptions
        TYPE string
        ASSERT $value != NONE
        COMMENT 'URI unique de l\'abonnement pour un principal donné.';

    DEFINE FIELD IF NOT EXISTS identity.displayname ON calendarsubscriptions
        TYPE string
        ASSERT $value != NONE
        COMMENT 'Nom d\'affichage de l\'abonnement.';
        
    DEFINE FIELD IF NOT EXISTS identity.source ON calendarsubscriptions
        TYPE string
        ASSERT string::is_url($value) = true
        COMMENT 'URL source de l\'abonnement. Ex: "webcal://example.com/calendar.ics".';

-- ============================================================================
-- BLOC METADATA : Métadonnées de l'abonnement
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON calendarsubscriptions
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées de l\'abonnement.';

    DEFINE FIELD IF NOT EXISTS metadata.lastmodified ON calendarsubscriptions
        TYPE int
        COMMENT 'Timestamp de la dernière modification de l\'abonnement.';
        
    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON calendarsubscriptions
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON calendarsubscriptions
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création de l\'abonnement.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON calendarsubscriptions
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT 'Date de dernière modification de l\'abonnement.';

-- ============================================================================
-- BLOC CONTENT : Configuration de l'abonnement
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON calendarsubscriptions
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : configuration et affichage de l\'abonnement.';

    DEFINE FIELD IF NOT EXISTS content.calendarcolor ON calendarsubscriptions
        TYPE string
        ASSERT string::is_hexadecimal($value) = true
        COMMENT 'Couleur associée à l\'abonnement.';
        
    DEFINE FIELD IF NOT EXISTS content.calendarorder ON calendarsubscriptions
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d\'affichage de l\'abonnement.';

    DEFINE FIELD IF NOT EXISTS content.refreshrate ON calendarsubscriptions
        TYPE string
        COMMENT 'Fréquence de rafraîchissement au format ISO 8601 Duration. Ex: "P1D" pour 1 jour.';

    DEFINE FIELD IF NOT EXISTS content.filters ON calendarsubscriptions
        TYPE object
        DEFAULT {}
        COMMENT 'Filtres à appliquer sur les événements de l\'abonnement.';

        DEFINE FIELD IF NOT EXISTS content.filters.stripalarms ON calendarsubscriptions
            TYPE bool
            DEFAULT false
            COMMENT 'Indique s\'il faut ignorer les alarmes de cet abonnement.';

        DEFINE FIELD IF NOT EXISTS content.filters.striptodos ON calendarsubscriptions
            TYPE bool
            DEFAULT false
            COMMENT 'Indique s\'il faut ignorer les tâches (VTODO) de cet abonnement.';

        DEFINE FIELD IF NOT EXISTS content.filters.stripattachments ON calendarsubscriptions
            TYPE bool
            DEFAULT false
            COMMENT 'Indique s\'il faut ignorer les pièces jointes de cet abonnement.';

-- ============================================================================
-- RELATIONS
-- ============================================================================

-- Le champ 'principaluri' a été retiré car chaque utilisateur opérera dans son propre namespace/DB,
-- rendant ce champ redondant. Une relation vers un 'workspace' pourra être ajoutée ici plus tard.

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_calsub_uri_unique ON calendarsubscriptions
    FIELDS identity.uri UNIQUE
    COMMENT 'Assure que l\'URI de l\'abonnement est unique pour cet utilisateur/namespace.';
