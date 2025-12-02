-- ============================================================================
-- TABLE : ui_component_library
-- Description : Bibliothèque de composants Lyxal Kit UI (créés uniquement)
-- Module : ui/library
-- ============================================================================

DEFINE TABLE IF NOT EXISTS ui_component_library TYPE NORMAL SCHEMAFULL
COMMENT 'Composants créés dans Lyxal Kit UI (pas d\'import externe - création uniquement)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE ui_component_library
    TYPE object
    COMMENT 'Bloc identité : identification unique du composant';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE ui_component_library
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : button, card, input, table, accordion';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE ui_component_library
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : button, card, input, table, accordion';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE ui_component_library
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Code unique du composant (snake_case) : button, contact_list';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE ui_component_library
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE ui_component_library
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du composant (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE ui_component_library
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du composant (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.preview_url ON TABLE ui_component_library
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de prévisualisation du composant (screenshot, SVG)';

    DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE ui_component_library
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés pour recherche : ["button", "form", "action", "ui"]';

-- ============================================================================
-- BLOC STRUCTURE : Configuration JSON complète (copie conforme)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS structure ON TABLE ui_component_library
    FLEXIBLE
    TYPE object
    COMMENT 'Configuration JSON complète du composant (copie conforme du .defaults.json)';

-- ============================================================================
-- BLOC CONFIG : Configuration du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE ui_component_library
    TYPE object
    COMMENT 'Bloc configuration : paramètres du composant';

    DEFINE FIELD IF NOT EXISTS config.category ON TABLE ui_component_library
        TYPE record<ui_component_library_category>
        REFERENCE ON DELETE REJECT
        COMMENT 'Référence vers la catégorie du composant';

    DEFINE FIELD IF NOT EXISTS config.version ON TABLE ui_component_library
        TYPE string
        DEFAULT '1.0.0'
        COMMENT 'Version du composant : 1.0.0, 2.1.3, etc.';

    DEFINE FIELD IF NOT EXISTS config.source ON TABLE ui_component_library
        TYPE string
        ASSERT $value INSIDE ['system', 'user_created']
        DEFAULT 'system'
        COMMENT 'Source du composant : system (composant système), user_created (créé par utilisateur)';

-- ============================================================================
-- BLOC STATUS : État du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE ui_component_library
    TYPE object
    COMMENT 'Bloc statut : état général du composant';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE ui_component_library
        TYPE bool
        DEFAULT true
        COMMENT 'Composant actif (disponible pour utilisation) ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_component ON TABLE ui_component_library
        TYPE bool
        DEFAULT true
        COMMENT 'Composant système (fourni par défaut) ou custom ?';

    DEFINE FIELD IF NOT EXISTS status.is_deprecated ON TABLE ui_component_library
        TYPE bool
        DEFAULT false
        COMMENT 'Composant déprécié (ne plus utiliser) ?';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE ui_component_library
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE ui_component_library
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre d\'utilisations du composant (analytics)';

    DEFINE FIELD IF NOT EXISTS metadata.last_used_at ON TABLE ui_component_library
        TYPE option<datetime>
        COMMENT 'Date de dernière utilisation';

    DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE ui_component_library
        TYPE option<array<record<tag>>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Tags pour classification : ["form", "data-display", "interactive"]';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE ui_component_library
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE ui_component_library
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE ui_component_library
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE ui_component_library
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_code ON ui_component_library
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_slug ON ui_component_library
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_value ON ui_component_library
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category ON ui_component_library
    FIELDS config.category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_active ON ui_component_library
    FIELDS status.is_active
    COMMENT 'Index sur les composants actifs';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_system ON ui_component_library
    FIELDS status.is_system_component
    COMMENT 'Index sur les composants système';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_source ON ui_component_library
    FIELDS config.source
    COMMENT 'Index sur la source du composant (system/user_created)';