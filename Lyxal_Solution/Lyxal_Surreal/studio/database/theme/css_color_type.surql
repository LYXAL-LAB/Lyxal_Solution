-- ============================================================================
-- TABLE : css_color_type
-- Description : Types de couleur CSS (primary, error, info, success, etc.) - Liste des 119 types
-- Module : studio/theme/css
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_color_type TYPE NORMAL SCHEMAFULL
COMMENT 'Types de couleur pour les thèmes du système Lyxal (primary, error, info, etc.)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du type de couleur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc identité : identification unique du type de couleur';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE css_color_type
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : primary, error, warning, info, success';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_color_type
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : primary, error, warning, info, success';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE css_color_type
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du type (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE css_color_type
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du type (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE css_color_type
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône du type';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation du type
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc contexte : où et comment le type est utilisé';

    DEFINE FIELD IF NOT EXISTS context.category ON TABLE css_color_type
        TYPE string
        ASSERT $value INSIDE ['semantic', 'brand', 'neutral', 'ui', 'state', 'feedback', 'custom']
        COMMENT 'Catégorie : semantic (primary, secondary), brand, neutral (gray, white), ui (background, surface), state (hover, active), feedback (error, success), custom';

    DEFINE FIELD IF NOT EXISTS context.usage_hints ON TABLE css_color_type
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Indications d\'usage : ["buttons", "text", "backgrounds", "borders", "alerts"]';

    DEFINE FIELD IF NOT EXISTS context.semantic_meaning ON TABLE css_color_type
        TYPE option<string>
        COMMENT 'Signification sémantique : "Couleur principale de la marque", "Indique une erreur", etc.';

-- ============================================================================
-- BLOC CONFIG : Configuration du type
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc configuration : paramètres du type';

    DEFINE FIELD IF NOT EXISTS config.requires_variants ON TABLE css_color_type
        TYPE bool
        DEFAULT false
        COMMENT 'Nécessite des variantes (light, dark, 50-900) ?';

    DEFINE FIELD IF NOT EXISTS config.default_variants ON TABLE css_color_type
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Variantes par défaut : ["main", "light", "dark"] ou ["50", "100", "200", ..., "900"]';

    DEFINE FIELD IF NOT EXISTS config.supports_alpha ON TABLE css_color_type
        TYPE bool
        DEFAULT true
        COMMENT 'Supporte la transparence (alpha) ?';

    DEFINE FIELD IF NOT EXISTS config.is_system_type ON TABLE css_color_type
        TYPE bool
        DEFAULT false
        COMMENT 'Type système (primary, error, etc.) ou type custom ?';

-- ============================================================================
-- BLOC STATUS : État du type
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc statut : état général du type';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE css_color_type
        TYPE bool
        DEFAULT true
        COMMENT 'Type actif dans le système ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE css_color_type
        TYPE bool
        DEFAULT false
        COMMENT 'Type par défaut ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE css_color_type
        TYPE string
        ASSERT $value INSIDE ['system', 'material_design', 'tailwind', 'bootstrap', 'custom', 'import', 'other']
        DEFAULT 'system'
        COMMENT 'Source du type';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_color_type
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE css_color_type
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE css_color_type
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS metadata.css_prefix ON TABLE css_color_type
        TYPE option<string>
        COMMENT 'Préfixe CSS : --color-primary, --color-error, etc.';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS created_at ON TABLE css_color_type
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création (readonly)';

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE css_color_type
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_color_type
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_css_color_type_slug ON css_color_type
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_css_color_type_value ON css_color_type
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_css_color_type_category ON css_color_type
    FIELDS context.category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS idx_css_color_type_active ON css_color_type
    FIELDS status.is_active
    COMMENT 'Index sur les types actifs';

DEFINE INDEX IF NOT EXISTS idx_css_color_type_system ON css_color_type
    FIELDS config.is_system_type
    COMMENT 'Index sur les types système';

DEFINE INDEX IF NOT EXISTS idx_css_color_type_order ON css_color_type
    FIELDS metadata.order
    COMMENT 'Index sur l\'ordre d\'affichage';

