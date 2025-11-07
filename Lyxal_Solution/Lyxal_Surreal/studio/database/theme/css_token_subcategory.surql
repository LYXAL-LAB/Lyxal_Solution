-- ============================================================================
-- TABLE : css_token_subcategory
-- Description : Sous-catégories des design tokens CSS
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_token_subcategory TYPE NORMAL SCHEMAFULL
COMMENT 'Sous-catégories des design tokens CSS (font-size, padding, border-radius, etc.)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC RELATIONS : Liens vers la catégorie parente
-- ============================================================================

DEFINE FIELD IF NOT EXISTS category ON TABLE css_token_subcategory
    TYPE record<css_token_category>
    REFERENCE ON DELETE CASCADE
    COMMENT 'Référence vers la catégorie parente';

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la sous-catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_token_subcategory
    TYPE object
    COMMENT 'Bloc identité : identification unique de la sous-catégorie';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE css_token_subcategory
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Nom de la sous-catégorie : font-size, padding, border-radius';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_token_subcategory
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z0-9_-]+$')
        COMMENT 'Slug URL-friendly : font-size, padding, border-radius';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE css_token_subcategory
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE css_token_subcategory
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la sous-catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE css_token_subcategory
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de la sous-catégorie (i18n)';

-- ============================================================================
-- BLOC METADATA : Informations complémentaires
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_token_subcategory
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_token_subcategory
        TYPE option<string>
        COMMENT 'Description détaillée de la sous-catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.unit ON TABLE css_token_subcategory
        TYPE option<string>
        COMMENT 'Unité par défaut pour cette sous-catégorie (rem, px, %, etc.)';

    DEFINE FIELD IF NOT EXISTS metadata.scale_type ON TABLE css_token_subcategory
        TYPE option<string>
        ASSERT $value == NONE OR $value IN ['linear', 'exponential', 'custom']
        DEFAULT 'linear'
        COMMENT 'Type d\'échelle : linear (1,2,3), exponential (1,2,4,8), custom';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE css_token_subcategory
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans la catégorie';

    DEFINE FIELD IF NOT EXISTS metadata.is_system ON TABLE css_token_subcategory
        TYPE bool
        DEFAULT false
        COMMENT 'Sous-catégorie système (non modifiable par les utilisateurs)';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_token_subcategory
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_token_subcategory
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_token_subcategory
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_token_subcategory_name ON css_token_subcategory
    FIELDS identity.name UNIQUE
    COMMENT 'Index unique sur le nom de la sous-catégorie';

DEFINE INDEX IF NOT EXISTS idx_token_subcategory_slug ON css_token_subcategory
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_token_subcategory_category ON css_token_subcategory
    FIELDS category
    COMMENT 'Index sur la catégorie parente';

DEFINE INDEX IF NOT EXISTS idx_token_subcategory_category_order ON css_token_subcategory
    FIELDS category, metadata.order
    COMMENT 'Index composite catégorie + ordre';

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Créer une sous-catégorie pour typography
-- CREATE css_token_subcategory:font_size SET
--   category = css_token_category:typography,
--   identity = {
--     name = "font-size",
--     slug = "font-size"
--   },
--   presentation = {
--     name_i18n = i18n_key:subcategory_font_size_name,
--     description_i18n = i18n_key:subcategory_font_size_description
--   },
--   metadata = {
--     description = "Tailles de police (xs, sm, md, lg, xl, 2xl, etc.)",
--     unit = "rem",
--     scale_type = "exponential",
--     order = 1,
--     is_system = true
--   };

-- Créer une sous-catégorie pour layout
-- CREATE css_token_subcategory:border_radius SET
--   category = css_token_category:layout,
--   identity = {
--     name = "border-radius",
--     slug = "border-radius"
--   },
--   presentation = {
--     name_i18n = i18n_key:subcategory_border_radius_name,
--     description_i18n = i18n_key:subcategory_border_radius_description
--   },
--   metadata = {
--     description = "Arrondis des bordures (none, sm, md, lg, xl, 2xl, full)",
--     unit = "rem",
--     scale_type = "linear",
--     order = 2,
--     is_system = true
--   };

-- Créer une nouvelle sous-catégorie personnalisée
-- CREATE css_token_subcategory:custom_effect SET
--   category = css_token_category:utility,
--   identity = {
--     name = "custom-effect",
--     slug = "custom-effect"
--   },
--   presentation = {
--     name_i18n = i18n_key:subcategory_custom_effect_name,
--     description_i18n = i18n_key:subcategory_custom_effect_description
--   },
--   metadata = {
--     description = "Effets personnalisés (blur, glow, etc.)",
--     unit = "px",
--     scale_type = "custom",
--     order = 100,
--     is_system = false
--   };

-- Requêtes typiques
-- SELECT * FROM css_token_subcategory WHERE category = css_token_category:typography ORDER BY metadata.order;
-- SELECT * FROM css_token_subcategory WHERE metadata.is_system = true;
