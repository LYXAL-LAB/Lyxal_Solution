-- ============================================================================
-- Fichier : knowledge/database/knowledge_category.surql
-- Module : knowledge
-- TABLE : knowledge_category
-- Description : Catégories principales pour organiser les topics par domaine
-- Internationalisé + enrichi pour usage UI et navigation
-- Dépendances : i18n_key
-- ============================================================================

DEFINE TABLE knowledge_category TYPE NORMAL SCHEMAFULL
    COMMENT 'Catégories principales permettant d organiser les topics par domaine'
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- IDENTITY : Identité de la catégorie + I18N + UI
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_category
    TYPE object
    COMMENT 'Bloc identité : code, i18n et UI slug';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE knowledge_category
        TYPE string
        ASSERT $value != NONE 
            AND $value != "" 
            AND string::len($value) > 0 
            AND string::uppercase($value) = $value
        COMMENT 'Code unique de la catégorie au format UPPER_SNAKE_CASE (ex: "DATA_DEFINITION", "QUERIES", "PERMISSIONS")';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_category
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Slug lisible pour URL / UI (ex: "data-definition", "queries", "permissions")';

    DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE knowledge_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : nom court de la catégorie (pour UI, menus, filtres)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description longue de la catégorie';

-- ============================================================================
-- METADATA : Métadonnées techniques
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_category
    TYPE object
    COMMENT 'Métadonnées techniques de la catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_category
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle de la catégorie (ex: "1.0.0", "2.1.0")';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_category
        TYPE bool
        DEFAULT true
        COMMENT 'La catégorie est active et peut être utilisée';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE knowledge_category
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d affichage pour UI (plus petit = affiché en premier)';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_category_code ON knowledge_category 
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code de la catégorie';

DEFINE INDEX idx_category_slug ON knowledge_category 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug pour navigation / UI / URL';

DEFINE INDEX idx_category_active ON knowledge_category 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif de la catégorie';

