-- ============================================================================
-- Fichier : calendar/share_types.surql
-- Module : calendar
-- TABLE : share_types
-- Description : Table de référence pour les types de ressources partageables.
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS share_types
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Table de référence pour les types de ressources partageables (ex: calendar).'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du type de partage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON share_types
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du type de partage.';

    DEFINE FIELD IF NOT EXISTS identity.code ON share_types
        TYPE string
        ASSERT $value != NONE AND string::uppercase($value) = $value
        COMMENT 'Code technique unique au format UPPER_SNAKE_CASE (ex: CALENDAR).';

    DEFINE FIELD IF NOT EXISTS identity.displayname ON share_types
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n pour le nom affiché du type de partage.';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_share_type_code_unique ON share_types
    FIELDS identity.code UNIQUE
    COMMENT 'Assure que le code du type de partage est unique.';

-- ============================================================================
-- SEEDING : Données initiales
-- ============================================================================

-- Le seeding sera géré ultérieurement dans des fichiers de fonctions dédiés.
-- Exemple :
-- INSERT IGNORE INTO share_types (id, identity) VALUES
--     ('calendar', { code: 'CALENDAR', displayname: i18n_key:share_type_calendar });
