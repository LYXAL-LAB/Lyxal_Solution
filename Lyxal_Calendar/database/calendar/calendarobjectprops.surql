-- ============================================================================
-- Fichier : calendar/calendarobjectprops.surql
-- Module : calendar
-- TABLE : calendarobjectprops
-- Description : Table d'optimisation pour la recherche sur les propriétés des événements.
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS calendarobjectprops
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Table des propriétés des objets de calendrier. Optimisation pour la recherche de propriétés d''événements.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC METADATA : Métadonnées de la propriété
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON calendarobjectprops
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées de la propriété.';

    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON calendarobjectprops
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON calendarobjectprops
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création de la propriété.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON calendarobjectprops
            TYPE datetime
            READONLY
            VALUE $value OR time::now()
            COMMENT 'Date de dernière modification de la propriété.';

-- ============================================================================
-- BLOC CONTENT : Données principales de la propriété
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON calendarobjectprops
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations de la propriété.';

    DEFINE FIELD IF NOT EXISTS content.name ON calendarobjectprops
        TYPE string
        ASSERT $value != NONE
        COMMENT 'Nom de la propriété iCalendar. Ex: "SUMMARY", "LOCATION", "DTSTART".';

    DEFINE FIELD IF NOT EXISTS content.parameter ON calendarobjectprops
        TYPE option<string>
        COMMENT 'Paramètre de la propriété iCalendar (peut être null).';

    DEFINE FIELD IF NOT EXISTS content.value ON calendarobjectprops
        TYPE string
        COMMENT 'Valeur de la propriété (tronquée à 255 caractères).';
        
-- ============================================================================
-- RELATIONS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS calendar ON calendarobjectprops 
    TYPE record<calendars>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au calendrier de l\'objet.';

DEFINE FIELD IF NOT EXISTS object ON calendarobjectprops 
    TYPE record<calendarobjects>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence à l\'objet de calendrier (événement/tâche).';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS calendarobject_index ON calendarobjectprops
    FIELDS object
    COMMENT 'Index pour retrouver les propriétés d''un objet spécifique.';

DEFINE INDEX IF NOT EXISTS calendarobject_name_index ON calendarobjectprops
    FIELDS content.name
    COMMENT 'Index pour rechercher des objets par nom de propriété.';

DEFINE INDEX IF NOT EXISTS calendarobject_value_index ON calendarobjectprops
    FIELDS content.value
    COMMENT 'Index pour rechercher des objets par valeur de propriété.';
