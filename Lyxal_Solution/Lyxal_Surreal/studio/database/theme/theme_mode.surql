-- ============================================================================
-- TABLE : theme_mode
-- Description : Modes de thème (light, dark, auto, custom)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS theme_mode TYPE NORMAL SCHEMAFULL
COMMENT 'Modes de thème pour l\'apparence de l\'interface (light, dark, auto, custom)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du mode
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc identité : identification unique du mode';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE theme_mode
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : light, dark, auto, custom';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE theme_mode
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : light, dark, auto, custom';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE theme_mode
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du mode (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE theme_mode
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du mode (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE theme_mode
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône représentative : ☀️, 🌙, 🔄, 🎨';

-- ============================================================================
-- BLOC CONFIG : Configuration du mode
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc configuration : paramètres du mode';

    DEFINE FIELD IF NOT EXISTS config.css_class ON TABLE theme_mode
        TYPE string
        COMMENT 'Classe CSS appliquée : "light", "dark", "auto", "custom"';

    DEFINE FIELD IF NOT EXISTS config.media_query ON TABLE theme_mode
        TYPE option<string>
        COMMENT 'Media query CSS pour le mode auto : "(prefers-color-scheme: dark)"';

    DEFINE FIELD IF NOT EXISTS config.fallback_mode ON TABLE theme_mode
        TYPE option<record<theme_mode>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Mode de fallback si auto ne peut pas être déterminé';

    DEFINE FIELD IF NOT EXISTS config.is_system_mode ON TABLE theme_mode
        TYPE bool
        DEFAULT true
        COMMENT 'Mode système (light, dark, auto) ou custom ?';

-- ============================================================================
-- BLOC STATUS : État du mode
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc statut : état général du mode';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE theme_mode
        TYPE bool
        DEFAULT true
        COMMENT 'Mode actif dans le système ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE theme_mode
        TYPE bool
        DEFAULT false
        COMMENT 'Mode par défaut ?';

    DEFINE FIELD IF NOT EXISTS status.order ON TABLE theme_mode
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS created_at ON TABLE theme_mode
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création (readonly)';

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE theme_mode
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE theme_mode
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_theme_mode_slug ON theme_mode
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_theme_mode_value ON theme_mode
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_theme_mode_active ON theme_mode
    FIELDS status.is_active
    COMMENT 'Index sur les modes actifs';

DEFINE INDEX IF NOT EXISTS idx_theme_mode_default ON theme_mode
    FIELDS status.is_default
    COMMENT 'Index sur le mode par défaut';

DEFINE INDEX IF NOT EXISTS idx_theme_mode_order ON theme_mode
    FIELDS status.order
    COMMENT 'Index sur l\'ordre d\'affichage';

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Mode light (système)
-- CREATE theme_mode:light SET
--   identity = { value = "light", slug = "light" },
--   presentation = {
--     name_i18n = i18n_key:theme_mode_light_name,
--     icon = icon:sun
--   },
--   config = {
--     css_class = "light",
--     is_system_mode = true
--   },
--   status = {
--     is_default = true,
--     order = 1
--   };

-- Mode dark (système)
-- CREATE theme_mode:dark SET
--   identity = { value = "dark", slug = "dark" },
--   presentation = {
--     name_i18n = i18n_key:theme_mode_dark_name,
--     icon = icon:moon
--   },
--   config = {
--     css_class = "dark",
--     is_system_mode = true
--   },
--   status = { order = 2 };

-- Mode auto (système)
-- CREATE theme_mode:auto SET
--   identity = { value = "auto", slug = "auto" },
--   presentation = {
--     name_i18n = i18n_key:theme_mode_auto_name,
--     icon = icon:rotate_cw
--   },
--   config = {
--     css_class = "auto",
--     media_query = "(prefers-color-scheme: dark)",
--     fallback_mode = theme_mode:light,
--     is_system_mode = true
--   },
--   status = { order = 3 };

-- Requêtes typiques
-- SELECT * FROM theme_mode WHERE status.is_active = true ORDER BY status.order;
-- SELECT * FROM theme_mode WHERE config.is_system_mode = true;