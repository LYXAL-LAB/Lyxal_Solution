-- ============================================================================
-- TABLE : theme
-- Description : Thèmes du système Lyxal (Light, Dark, Custom, etc.)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS theme TYPE NORMAL SCHEMAFULL
COMMENT 'Thèmes du système Lyxal pour customisation de l\'interface'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du thème
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE theme
    TYPE object
    COMMENT 'Bloc identité : identification unique du thème';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE theme
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : lyxal_default_light, custom_dark_blue';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE theme
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : lyxal-default-light, custom-dark-blue';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE theme
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE theme
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du thème (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE theme
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du thème (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE theme
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône du thème : 🌞, 🌙, 🎨';

    DEFINE FIELD IF NOT EXISTS presentation.preview_url ON TABLE theme
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de prévisualisation du thème (screenshot, SVG)';

-- ============================================================================
-- BLOC CONFIG : Configuration du thème
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE theme
    TYPE object
    COMMENT 'Bloc configuration : paramètres du thème';

    DEFINE FIELD IF NOT EXISTS config.mode ON TABLE theme
        TYPE record<theme_mode>
        REFERENCE ON DELETE REJECT
        VALUE type::record('theme_mode', $value)
        COMMENT 'Mode du thème : light, dark, auto, custom';

    DEFINE FIELD IF NOT EXISTS config.base_theme ON TABLE theme
        TYPE option<record<theme>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::record('theme', $value)} ELSE {NONE}}
        COMMENT 'Thème de base (pour extension/override)';

    DEFINE FIELD IF NOT EXISTS config.css_framework ON TABLE theme
        TYPE record<css_framework>
        REFERENCE ON DELETE REJECT
        VALUE type::record('css_framework', $value)
        COMMENT 'Framework CSS utilisé : tailwind, material_design, bootstrap, custom, css_variables';

    DEFINE FIELD IF NOT EXISTS config.icon_provider ON TABLE theme
        TYPE record<icon_provider>
        REFERENCE ON DELETE REJECT
        VALUE type::record('icon_provider', $value)
        COMMENT 'Pack d\'icônes utilisé par ce thème : Lucide, Heroicons, Material Icons, etc.';

    DEFINE FIELD IF NOT EXISTS config.is_system_theme ON TABLE theme
        TYPE bool
        DEFAULT false
        COMMENT 'Thème système (fourni par défaut) ou custom (créé par utilisateur) ?';

    DEFINE FIELD IF NOT EXISTS config.is_inheritable ON TABLE theme
        TYPE bool
        DEFAULT true
        COMMENT 'Peut servir de base pour d\'autres thèmes ?';

-- ============================================================================
-- BLOC TAILWIND : Configuration Tailwind spécifique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS tailwind ON TABLE theme
    TYPE option<object>
    COMMENT 'Bloc Tailwind : configuration spécifique pour Tailwind CSS';

    DEFINE FIELD IF NOT EXISTS tailwind.config_json ON TABLE theme
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Configuration Tailwind au format JSON (theme.extend.colors)';

    DEFINE FIELD IF NOT EXISTS tailwind.safelist ON TABLE theme
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Classes Tailwind à inclure dans le build : ["bg-primary-500", "text-error-main"]';

    DEFINE FIELD IF NOT EXISTS tailwind.plugin_config ON TABLE theme
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Configuration des plugins Tailwind (custom)';

-- ============================================================================
-- BLOC METADATA : Métadonnées du thème
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE theme
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE theme
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE theme
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::record('identity', $value)} ELSE {NONE}}
        COMMENT 'Utilisateur créateur du thème (si custom)';

    DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE theme
        TYPE option<string>
        DEFAULT '1.0.0'
        COMMENT 'Version du thème : 1.0.0, 2.1.3, etc.';

    DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE theme
        TYPE option<array<record<tag>>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::record('tag', $value)} ELSE {NONE}}
        COMMENT 'Tags : ["corporate", "colorful", "minimalist", "high-contrast"]';

-- ============================================================================
-- BLOC STATUS : État du thème
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE theme
    TYPE object
    COMMENT 'Bloc statut : état général du thème';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE theme
        TYPE bool
        DEFAULT true
        COMMENT 'Thème actif (disponible pour sélection) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE theme
        TYPE bool
        DEFAULT false
        COMMENT 'Thème par défaut du système ?';

    DEFINE FIELD IF NOT EXISTS status.is_public ON TABLE theme
        TYPE bool
        DEFAULT false
        COMMENT 'Thème public (partageable) ou privé (usage personnel) ?';

    DEFINE FIELD IF NOT EXISTS status.visibility ON TABLE theme
        TYPE string
        ASSERT $value INSIDE ['public', 'private', 'organization', 'system']
        DEFAULT 'private'
        COMMENT 'Visibilité du thème : public, private, organization, system';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE theme
        TYPE string
        ASSERT $value INSIDE ['system', 'user_created', 'import', 'generated', 'marketplace', 'other']
        DEFAULT 'system'
        COMMENT 'Source du thème';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================
DEFINE FIELD IF NOT EXISTS timestamp ON TABLE theme
    TYPE OBJECT
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE theme
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE theme
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE theme
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_theme_slug ON theme
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_theme_value ON theme
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_theme_mode ON theme
    FIELDS config.mode
    COMMENT 'Index sur le mode du thème (light/dark)';

DEFINE INDEX IF NOT EXISTS idx_theme_active ON theme
    FIELDS status.is_active
    COMMENT 'Index sur les thèmes actifs';

DEFINE INDEX IF NOT EXISTS idx_theme_default ON theme
    FIELDS status.is_default
    COMMENT 'Index sur le thème par défaut';

DEFINE INDEX IF NOT EXISTS idx_theme_visibility ON theme
    FIELDS status.visibility
    COMMENT 'Index sur la visibilité du thème';

DEFINE INDEX IF NOT EXISTS idx_theme_system ON theme
    FIELDS config.is_system_theme
    COMMENT 'Index sur les thèmes système';

DEFINE INDEX IF NOT EXISTS idx_theme_author ON theme
    FIELDS metadata.author_user_id
    COMMENT 'Index sur l\'auteur du thème';

