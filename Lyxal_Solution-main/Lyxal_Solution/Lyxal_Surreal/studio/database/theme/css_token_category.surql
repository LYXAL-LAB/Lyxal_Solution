-- ============================================================================
-- TABLE : css_token_category
-- Description : Catégories des design tokens CSS
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_token_category TYPE NORMAL SCHEMAFULL
COMMENT 'Catégories des design tokens CSS (spacing, typography, layout, etc.)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_token_category
    TYPE object
    COMMENT 'Bloc identité : identification unique de la catégorie';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE css_token_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Nom de la catégorie : spacing, typography, layout, component, utility';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_token_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z0-9_-]+$')
        COMMENT 'Slug URL-friendly : spacing, typography, layout';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE css_token_category
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE css_token_category
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE css_token_category
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE css_token_category
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône représentative de la catégorie';

-- ============================================================================
-- BLOC METADATA : Informations complémentaires
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_token_category
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_token_category
        TYPE option<string>
        COMMENT 'Description détaillée de la catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.color ON TABLE css_token_category
        TYPE option<record<theme_color>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Couleur représentative depuis theme_color (pour l\'interface admin)';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE css_token_category
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS metadata.is_system ON TABLE css_token_category
        TYPE bool
        DEFAULT false
        COMMENT 'Catégorie système (non modifiable par les utilisateurs)';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_token_category
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_token_category
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_token_category
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_token_category_name ON css_token_category
    FIELDS identity.name UNIQUE
    COMMENT 'Index unique sur le nom de la catégorie';

DEFINE INDEX IF NOT EXISTS idx_token_category_slug ON css_token_category
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_token_category_order ON css_token_category
    FIELDS metadata.order
    COMMENT 'Index sur l\'ordre d\'affichage';

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Créer une catégorie de base
-- CREATE css_token_category:spacing SET
--   identity = {
--     name = "spacing",
--     slug = "spacing"
--   },
--   presentation = {
--     name_i18n = i18n_key:category_spacing_name,
--     description_i18n = i18n_key:category_spacing_description
--   },
--   metadata = {
--     description = "Tokens d'espacement (padding, margin)",
--     color = theme_color:primary_500,  // Référence vers theme_color
--     order = 1,
--     is_system = true
--   };

-- Créer une nouvelle catégorie personnalisée
-- CREATE css_token_category:shadows SET
--   identity = {
--     name = "shadows",
--     slug = "shadows"
--   },
--   presentation = {
--     name_i18n = i18n_key:category_shadows_name,
--     description_i18n = i18n_key:category_shadows_description
--   },
--   metadata = {
--     description = "Tokens d'ombres et effets visuels",
--     color = theme_color:secondary_400,  // Référence vers theme_color
--     order = 10,
--     is_system = false
--   };

-- Requêtes typiques
-- SELECT * FROM css_token_category ORDER BY metadata.order;
-- SELECT * FROM css_token_category WHERE metadata.is_system = true;
