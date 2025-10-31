-- =====================================================================================
-- TABLE: gender
-- Description: Genres/Sexes
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS gender SCHEMAFULL
    COMMENT 'Genres/Sexes des entrepreneurs individuels'
    PERMISSIONS
        FOR select FULL;
        FOR create, update, delete NONE;
-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE gender
    TYPE string
    COMMENT 'Code  (M, F, ND)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE gender
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé du genre';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE gender
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE gender FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de genre';