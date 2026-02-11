-- ============================================================================
-- Fichier : calendar/schedulingobjects.surql
-- Module : calendar
-- TABLE : schedulingobjects
-- Description : Boîte de réception pour les objets de planification (invitations iTIP).
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
--
-- REFLEXION D'ARCHITECTURE :
-- Cette table agit comme une "inbox" temporaire pour les invitations. Un processus
-- devra traiter ces objets : quand un utilisateur accepte une invitation, l'objet
-- est supprimé de cette table et un `calendarobject` est créé dans son calendrier.
-- Le champ `principaluri` est retiré car redondant dans une architecture multi-tenant
-- avec un namespace par utilisateur.
-- ============================================================================

DEFINE TABLE IF NOT EXISTS schedulingobjects
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Boîte de réception pour les objets de planification (invitations, réponses iTIP).'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'objet de planification
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON schedulingobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de l\'objet de planification.';

    DEFINE FIELD IF NOT EXISTS identity.uri ON schedulingobjects
        TYPE string
        ASSERT $value != NONE
        COMMENT 'URI unique de l\'objet de planification.';

-- ============================================================================
-- BLOC METADATA : Métadonnées de l'objet
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON schedulingobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées de l\'objet.';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON schedulingobjects
        TYPE uuid
        READONLY
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'Entity Tag pour la gestion du cache HTTP (ETag).';

    DEFINE FIELD IF NOT EXISTS metadata.size ON schedulingobjects
        TYPE int
        COMMENT 'Taille de l\'objet calendardata en octets.';

    DEFINE FIELD IF NOT EXISTS metadata.lastmodified ON schedulingobjects
        TYPE int
        COMMENT 'Timestamp (entier) de la dernière modification pour compatibilité CalDAV.';
        
    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON schedulingobjects
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON schedulingobjects
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de réception de l\'objet.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON schedulingobjects
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT 'Date de dernière modification de l\'objet.';
            
-- ============================================================================
-- BLOC CONTENT : Données de l'objet de planification
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON schedulingobjects
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations de l\'objet de planification.';
    
    DEFINE FIELD IF NOT EXISTS content.calendardata ON schedulingobjects
        TYPE string
        COMMENT 'Contenu complet de l\'objet au format iCalendar (iTIP).';

-- ============================================================================
-- INDEX
-- ============================================================================
  
DEFINE INDEX IF NOT EXISTS idx_scheduling_uri_unique ON schedulingobjects
    FIELDS identity.uri UNIQUE
    COMMENT 'Assure que l\'URI de l\'objet de planification est unique.';

DEFINE INDEX IF NOT EXISTS idx_scheduling_lastmodified ON schedulingobjects
    FIELDS metadata.lastmodified
    COMMENT 'Index sur la date de modification pour des tris rapides.';
