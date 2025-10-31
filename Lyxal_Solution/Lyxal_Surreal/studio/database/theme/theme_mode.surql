-- ============================================================================
-- TABLE : theme_mode
-- Description : Modes de thème (light, dark, auto, custom)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS theme_mode TYPE NORMAL SCHEMAFULL
COMMENT 'Modes de thème disponibles pour le système Lyxal'
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
        VALUE type::record('i18n_key', $value)
        COMMENT 'Nom du mode (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE theme_mode
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::record('i18n_key', $value)} ELSE {NONE}}
        COMMENT 'Description du mode (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE theme_mode
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::record('icon', $value)} ELSE {NONE}}
        COMMENT 'Icône du mode : 🌞 (light), 🌙 (dark), 🔄 (auto), 🎨 (custom)';

-- ============================================================================
-- BLOC CONFIG : Configuration du mode
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc configuration : paramètres du mode';

    DEFINE FIELD IF NOT EXISTS config.applies_to_system ON TABLE theme_mode
        TYPE bool
        DEFAULT true
        COMMENT 'S\'applique au système (auto-detect) ou défini manuellement ?';

    DEFINE FIELD IF NOT EXISTS config.media_query ON TABLE theme_mode
        TYPE option<string>
        COMMENT 'Media query CSS : prefers-color-scheme: dark, etc.';

    DEFINE FIELD IF NOT EXISTS config.is_system_mode ON TABLE theme_mode
        TYPE bool
        DEFAULT false
        COMMENT 'Mode système (light, dark, auto) ou mode custom ?';

-- ============================================================================
-- BLOC STATUS : État du mode
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc statut : état général du mode';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE theme_mode
        TYPE bool
        DEFAULT true
        COMMENT 'Mode actif (disponible pour sélection) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE theme_mode
        TYPE bool
        DEFAULT false
        COMMENT 'Mode par défaut du système ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE theme_mode
        TYPE string
        ASSERT $value INSIDE ['system', 'custom']
        DEFAULT 'system'
        COMMENT 'Source du mode';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE theme_mode
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE theme_mode
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE theme_mode
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE theme_mode
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE theme_mode
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE theme_mode
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

DEFINE INDEX IF NOT EXISTS idx_theme_mode_system ON theme_mode
    FIELDS config.is_system_mode
    COMMENT 'Index sur les modes système';

DEFINE INDEX IF NOT EXISTS idx_theme_mode_order ON theme_mode
    FIELDS metadata.order
    COMMENT 'Index sur l\'ordre d\'affichage';

