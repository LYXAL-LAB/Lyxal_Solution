-- ============================================================================
-- TABLE : icon_style
-- Description : Styles d'icônes disponibles (stroke, solid, duotone, mixed, custom)
-- Module : studio/icon
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_style TYPE NORMAL SCHEMAFULL
COMMENT 'Styles d\'icônes disponibles pour le système Lyxal'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du style
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_style
    TYPE object
    COMMENT 'Bloc identité : identification unique du style';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE icon_style
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : stroke, solid, duotone, mixed, custom';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_style
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : stroke, solid, duotone, mixed, custom';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon_style
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE icon_style
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du style (i18n) : "Stroke (Outline)", "Solid (Filled)"';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE icon_style
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du style (i18n)';

-- ============================================================================
-- BLOC METADATA : Métadonnées du style
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_style
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.technical_name ON TABLE icon_style
        TYPE option<string>
        COMMENT 'Nom technique CSS/SVG : outline, filled, duo-tone';

    DEFINE FIELD IF NOT EXISTS metadata.preview_example ON TABLE icon_style
        TYPE option<string>
        COMMENT 'Exemple de code SVG ou classe CSS pour prévisualisation';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE icon_style
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE icon_style
        TYPE option<string>
        COMMENT 'Notes internes libres';

-- ============================================================================
-- BLOC STATUS : État du style
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon_style
    TYPE object
    COMMENT 'Bloc statut : état général du style';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon_style
        TYPE bool
        DEFAULT true
        COMMENT 'Style actif (disponible pour sélection) ?';

    DEFINE FIELD IF NOT EXISTS status.is_system ON TABLE icon_style
        TYPE bool
        DEFAULT true
        COMMENT 'Style système (non modifiable) ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE icon_style
        TYPE string
        ASSERT $value INSIDE ['system', 'custom']
        DEFAULT 'system'
        COMMENT 'Source du style';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon_style
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE icon_style
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE icon_style
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE icon_style
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_style_slug ON icon_style
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_style_value ON icon_style
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_icon_style_active ON icon_style
    FIELDS status.is_active
    COMMENT 'Index sur les styles actifs';

DEFINE INDEX IF NOT EXISTS idx_icon_style_order ON icon_style
    FIELDS metadata.display_order
    COMMENT 'Index sur l\'ordre d\'affichage';

