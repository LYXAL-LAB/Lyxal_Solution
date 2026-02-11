-- ============================================================================
-- Fichier : calendar/calendarchanges.surql
-- Module : calendar
-- TABLE : calendarchanges
-- Description : Table pour la synchronisation CalDAV. Log chaque modification.
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS calendarchanges
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Enregistre les modifications (ajout, modif, suppr) pour la synchronisation CalDAV.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC METADATA : Métadonnées du changement
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON calendarchanges
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées du changement.';

    DEFINE FIELD IF NOT EXISTS metadata.synctoken ON calendarchanges
        TYPE int
        ASSERT $value > 0
        COMMENT 'Le jeton de synchronisation au moment où le changement a eu lieu.';
        
    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON calendarchanges
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : date de création.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON calendarchanges
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création de l\'entrée de log.';

-- ============================================================================
-- BLOC CONTENT : Données principales du changement
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON calendarchanges
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations du changement.';

    DEFINE FIELD IF NOT EXISTS content.uri ON calendarchanges
        TYPE string
        ASSERT $value != NONE
        COMMENT 'URI de l\'objet qui a été modifié ou supprimé.';

    -- L'opération effectuée, en référence à la table `operations`
    DEFINE FIELD IF NOT EXISTS content.operation ON calendarchanges
        TYPE record<operations>
        REFERENCE ON DELETE REJECT
        COMMENT 'L\'opération effectuée (référence à la table operations).';

-- ============================================================================
-- RELATIONS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS calendar ON calendarchanges 
    TYPE record<calendars>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au calendrier où le changement a eu lieu.';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_calendar_synctoken ON calendarchanges
    FIELDS calendar, metadata.synctoken
    COMMENT 'Index pour récupérer efficacement les changements pour un calendrier depuis un certain synctoken.';
