-- ============================================================================
-- Fichier : calendar/access_levels.surql
-- Module : calendar
-- TABLE : access_levels
-- Description : Table de référence pour les niveaux de permission des partages.
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS access_levels
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Table de référence pour les niveaux de permission des partages (ex: lecture, écriture).'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du niveau d'accès
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON access_levels
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du niveau d''accès.';

    DEFINE FIELD IF NOT EXISTS identity.code ON access_levels
        TYPE string
        ASSERT $value != NONE AND string::uppercase($value) = $value
        COMMENT 'Code technique unique au format UPPER_SNAKE_CASE (ex: READ, WRITE).';

    DEFINE FIELD IF NOT EXISTS identity.level ON access_levels
        TYPE int
        ASSERT $value != NONE
        COMMENT 'Valeur numérique du niveau, pour comparaisons faciles (ex: 1 pour READ, 2 pour WRITE).';

    DEFINE FIELD IF NOT EXISTS identity.displayname ON access_levels
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n pour le nom affiché du niveau d''accès.';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_access_level_code_unique ON access_levels
    FIELDS identity.code UNIQUE
    COMMENT 'Assure que le code du niveau d''accès est unique.';

DEFINE INDEX IF NOT EXISTS idx_access_level_level_unique ON access_levels
    FIELDS identity.level UNIQUE
    COMMENT 'Assure que le niveau numérique est unique.';
    
-- ============================================================================
-- SEEDING : Données initiales
-- ============================================================================

-- Le seeding sera géré ultérieurement dans des fichiers de fonctions dédiés.
-- Exemples :
-- INSERT IGNORE INTO access_levels (id, identity) VALUES
--     ('read', { code: 'READ', level: 1, displayname: i18n_key:access_level_read }),
--     ('write', { code: 'WRITE', level: 2, displayname: i18n_key:access_level_write });
