-- ============================================================================
-- TABLE : icon_usage
-- Description : Relation de graphe entre une définition sémantique et une icône technique
-- Type : RELATION (edge)
-- Module : Lyxal_SVG
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_usage SCHEMAFULL
    TYPE RELATION IN icon_dictionary OUT icon ENFORCED
    COMMENT 'Relation définissant quelle icône technique est utilisée par quel concept sémantique'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- METADATA RELATION
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE icon_usage
    TYPE string
    DEFAULT 'default'
    COMMENT 'Contexte d\'usage (default, dark_mode, mobile, print)';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE icon_usage
    TYPE datetime
    DEFAULT time::now()
    READONLY;

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_usage_unique ON icon_usage COLUMNS in, out, context UNIQUE;
