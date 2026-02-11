-- ============================================================================
-- TABLE : css_framework
-- Description : Frameworks CSS disponibles (Tailwind, Material Design, Bootstrap, etc.)
-- Module : studio/theme
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_framework TYPE NORMAL SCHEMAFULL
COMMENT 'Frameworks CSS disponibles pour les thèmes Lyxal'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du framework
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE css_framework
    TYPE object
    COMMENT 'Bloc identité : identification unique du framework';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE css_framework
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : tailwind, material_design, bootstrap';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE css_framework
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : tailwind, material-design, bootstrap';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE css_framework
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE css_framework
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du framework (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE css_framework
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du framework (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon_light ON TABLE css_framework
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône du framework pour thème clair';

    DEFINE FIELD IF NOT EXISTS presentation.icon_dark ON TABLE css_framework
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Icône du framework pour thème sombre';

-- ============================================================================
-- BLOC CONFIG : Configuration du framework
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE css_framework
    TYPE object
    COMMENT 'Bloc configuration : paramètres du framework';

    DEFINE FIELD IF NOT EXISTS config.type ON TABLE css_framework
        TYPE string
        ASSERT $value INSIDE ['utility_first', 'component_based', 'css_variables', 'preprocessor', 'custom']
        DEFAULT 'utility_first'
        COMMENT 'Type de framework : utility_first (Tailwind), component_based (Material), css_variables, preprocessor (SASS/LESS), custom';

    DEFINE FIELD IF NOT EXISTS config.default_config ON TABLE css_framework
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Configuration par défaut du framework (JSON)';

    DEFINE FIELD IF NOT EXISTS config.supported_features ON TABLE css_framework
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Fonctionnalités supportées : ["dark_mode", "responsive", "animations", "custom_colors"]';

    DEFINE FIELD IF NOT EXISTS config.version ON TABLE css_framework
        TYPE option<string>
        COMMENT 'Version du framework : 3.4.0, 5.3.0, etc.';

    DEFINE FIELD IF NOT EXISTS config.dependencies ON TABLE css_framework
        TYPE option<object>
        COMMENT 'Dépendances CSS/JS requises par le framework';

        DEFINE FIELD config.dependencies.css_urls ON TABLE css_framework
            TYPE option<array<record<url>>>
            COMMENT 'URLs des fichiers CSS à charger depuis la table url';

        DEFINE FIELD config.dependencies.js_urls ON TABLE css_framework
            TYPE option<array<record<url>>>
            COMMENT 'URLs des fichiers JS à charger depuis la table url';

        DEFINE FIELD config.dependencies.font_urls ON TABLE css_framework
            TYPE option<array<record<url>>>
            COMMENT 'URLs des polices à charger depuis la table url';

-- ============================================================================
-- BLOC DOCUMENTATION : Documentation du framework
-- ============================================================================

DEFINE FIELD IF NOT EXISTS documentation ON TABLE css_framework
    TYPE option<object>
    COMMENT 'Bloc documentation : liens et ressources';

    DEFINE FIELD IF NOT EXISTS documentation.official_url ON TABLE css_framework
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL officielle du framework';

    DEFINE FIELD IF NOT EXISTS documentation.docs_url ON TABLE css_framework
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de la documentation';

    DEFINE FIELD IF NOT EXISTS documentation.github_url ON TABLE css_framework
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL du repository GitHub';

-- ============================================================================
-- BLOC STATUS : État du framework
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE css_framework
    TYPE object
    COMMENT 'Bloc statut : état général du framework';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE css_framework
        TYPE bool
        DEFAULT true
        COMMENT 'Framework actif (disponible pour sélection) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE css_framework
        TYPE bool
        DEFAULT false
        COMMENT 'Framework par défaut du système ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE css_framework
        TYPE string
        ASSERT $value INSIDE ['system', 'custom', 'import']
        DEFAULT 'system'
        COMMENT 'Source du framework';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_framework
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE css_framework
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE css_framework
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS metadata.examples ON TABLE css_framework
        FLEXIBLE
        TYPE option<array<object>>
        COMMENT 'Exemples d\'usage du framework : [{title, description, code}]';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE css_framework
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE css_framework
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE css_framework
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_framework
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_css_framework_slug ON css_framework
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_css_framework_value ON css_framework
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_css_framework_type ON css_framework
    FIELDS config.type
    COMMENT 'Index sur le type de framework';

DEFINE INDEX IF NOT EXISTS idx_css_framework_active ON css_framework
    FIELDS status.is_active
    COMMENT 'Index sur les frameworks actifs';

DEFINE INDEX IF NOT EXISTS idx_css_framework_default ON css_framework
    FIELDS status.is_default
    COMMENT 'Index sur le framework par défaut';

DEFINE INDEX IF NOT EXISTS idx_css_framework_order ON css_framework
    FIELDS metadata.order
    COMMENT 'Index sur l\'ordre d\'affichage';

