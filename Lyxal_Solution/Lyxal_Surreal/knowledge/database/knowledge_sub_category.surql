-- ============================================================================
-- Fichier : knowledge/database/knowledge_sub_category.surql
-- Module : knowledge
-- TABLE : knowledge_sub_category
-- Description : Sous-catégories optionnelles pour affiner l'organisation des topics
-- Internationalisé + enrichi pour usage UI et navigation
-- Dépendances : i18n_key, knowledge_category
-- ============================================================================

DEFINE TABLE knowledge_sub_category TYPE NORMAL SCHEMAFULL
    COMMENT 'Sous-catégories optionnelles permettant d affiner l organisation des topics'
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- RELATION : Lien vers la catégorie parente
-- ============================================================================
DEFINE FIELD IF NOT EXISTS category ON TABLE knowledge_sub_category
    TYPE record<knowledge_category>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT 'Catégorie parente à laquelle appartient cette sous-catégorie - Supprimée automatiquement si la catégorie est supprimée';

-- ============================================================================
-- IDENTITY : Identité de la sous-catégorie + I18N + UI
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_sub_category
    TYPE object
    COMMENT 'Bloc identité : code, i18n et UI slug';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE knowledge_sub_category
        TYPE string
        ASSERT $value != NONE 
            AND $value != "" 
            AND string::len($value) > 0 
            AND string::uppercase($value) = $value
        COMMENT 'Code unique de la sous-catégorie au format UPPER_SNAKE_CASE (ex: "FIELD_TYPES", "INDEX_TYPES", "QUERY_FILTERS")';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_sub_category
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Slug lisible pour URL / UI (ex: "field-types", "index-types", "query-filters")';

    DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE knowledge_sub_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : nom court de la sous-catégorie (pour UI, menus, filtres)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_sub_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description longue de la sous-catégorie';

-- ============================================================================
-- METADATA : Métadonnées techniques
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_sub_category
    TYPE object
    COMMENT 'Métadonnées techniques de la sous-catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_sub_category
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle de la sous-catégorie (ex: "1.0.0", "2.1.0")';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_sub_category
        TYPE bool
        DEFAULT true
        COMMENT 'La sous-catégorie est active et peut être utilisée';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE knowledge_sub_category
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d affichage pour UI (plus petit = affiché en premier)';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_sub_category_code ON knowledge_sub_category 
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code de la sous-catégorie';

DEFINE INDEX idx_sub_category_slug ON knowledge_sub_category 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug pour navigation / UI / URL';

DEFINE INDEX idx_sub_category_category ON knowledge_sub_category 
    FIELDS category
    COMMENT 'Index sur la catégorie parente pour jointures rapides';

DEFINE INDEX idx_sub_category_active ON knowledge_sub_category 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif de la sous-catégorie';

