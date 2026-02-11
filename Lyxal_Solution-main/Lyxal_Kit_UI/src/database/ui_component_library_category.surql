-- ============================================================================
-- TABLE : ui_component_library_category
-- Description : Catégories de composants pour Lyxal Kit UI
-- Module : ui/library
-- ============================================================================

DEFINE TABLE IF NOT EXISTS ui_component_library_category TYPE NORMAL SCHEMAFULL
COMMENT 'Catégories organisationnelles pour les composants UI du design system Lyxal Kit UI'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE ui_component_library_category
    TYPE object
    COMMENT 'Bloc identité : identification unique de la catégorie';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE ui_component_library_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : layout, input, data-display, navigation';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE ui_component_library_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : layout, input, data-display, navigation';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE ui_component_library_category
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Code unique de la catégorie (snake_case) : layout, data_display';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE ui_component_library_category
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE ui_component_library_category
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE ui_component_library_category
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de la catégorie (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE ui_component_library_category
        TYPE option<record<icon>>
        REFERENCE ON DELETE UNSET
        DEFAULT NONE
        COMMENT 'Icône Lucide React associée à la catégorie';

    DEFINE FIELD IF NOT EXISTS presentation.color ON TABLE ui_component_library_category
        TYPE string
        DEFAULT "#6b7280"
        COMMENT 'Couleur hexadécimale pour l\'identité visuelle : #3b82f6, #10b981';

-- ============================================================================
-- BLOC CONFIG : Configuration de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE ui_component_library_category
    TYPE object
    COMMENT 'Bloc configuration : paramètres de la catégorie';

    DEFINE FIELD IF NOT EXISTS config.order ON TABLE ui_component_library_category
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans les listes et menus (0 = premier)';

    DEFINE FIELD IF NOT EXISTS config.is_visible ON TABLE ui_component_library_category
        TYPE bool
        DEFAULT true
        COMMENT 'Catégorie visible dans l\'interface utilisateur ?';

-- ============================================================================
-- BLOC STATUS : État de la catégorie
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE ui_component_library_category
    TYPE object
    COMMENT 'Bloc statut : état général de la catégorie';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE ui_component_library_category
        TYPE bool
        DEFAULT true
        COMMENT 'Catégorie active (utilisable) ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_category ON TABLE ui_component_library_category
        TYPE bool
        DEFAULT true
        COMMENT 'Catégorie système (fournie par défaut) ou custom ?';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE ui_component_library_category
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.component_count ON TABLE ui_component_library_category
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de composants dans cette catégorie (calculé)';

    DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE ui_component_library_category
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre d\'utilisations de composants de cette catégorie';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE ui_component_library_category
    TYPE object
    DEFAULT {}
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE ui_component_library_category
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE ui_component_library_category
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE ui_component_library_category
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_code ON ui_component_library_category
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_slug ON ui_component_library_category
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_value ON ui_component_library_category
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_active ON ui_component_library_category
    FIELDS status.is_active
    COMMENT 'Index sur les catégories actives';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_visible ON ui_component_library_category
    FIELDS config.is_visible
    COMMENT 'Index sur les catégories visibles';

DEFINE INDEX IF NOT EXISTS idx_ui_component_library_category_order ON ui_component_library_category
    FIELDS config.order
    COMMENT 'Index sur l\'ordre d\'affichage';