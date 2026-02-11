-- ============================================================================
-- TABLE : icon_provider
-- Description : Fournisseurs d'icônes (Lucide, Heroicons, Material Icons, etc.)
-- Module : studio/icon
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_provider TYPE NORMAL SCHEMAFULL
COMMENT 'Fournisseurs d\'icônes disponibles pour le système Lyxal'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du fournisseur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_provider
    TYPE object
    COMMENT 'Bloc identité : identification unique du fournisseur';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE icon_provider
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : lucide, heroicons, material_icons, font_awesome';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_provider
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : lucide, heroicons, material-icons, font-awesome';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon_provider
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE icon_provider
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du fournisseur (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE icon_provider
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du fournisseur (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.logo ON TABLE icon_provider
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Logo du fournisseur (géré via le système icon, catégorie brand)';

-- ============================================================================
-- BLOC CONFIG : Configuration du fournisseur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE icon_provider
    TYPE object
    COMMENT 'Bloc configuration : paramètres du fournisseur';

    DEFINE FIELD IF NOT EXISTS config.base_url ON TABLE icon_provider
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de base du CDN : https://icons.lyxal.b-cdn.net/lucide/';

    DEFINE FIELD IF NOT EXISTS config.version ON TABLE icon_provider
        TYPE option<string>
        COMMENT 'Version du pack d\'icônes : 0.344.0, 2.0.0, etc.';

    DEFINE FIELD IF NOT EXISTS config.license ON TABLE icon_provider
        TYPE option<string>
        COMMENT 'Licence : MIT, ISC, Apache-2.0, etc.';

    DEFINE FIELD IF NOT EXISTS config.total_icons ON TABLE icon_provider
        TYPE option<int>
        COMMENT 'Nombre total d\'icônes disponibles dans ce pack';

    DEFINE FIELD IF NOT EXISTS config.style ON TABLE icon_provider
        TYPE record<icon_style>
        REFERENCE ON DELETE REJECT
        COMMENT 'Style des icônes : stroke (outline), solid (filled), duotone, mixed, custom';

    DEFINE FIELD IF NOT EXISTS config.formats ON TABLE icon_provider
        TYPE option<array<string>>
        DEFAULT ['svg']
        COMMENT 'Formats disponibles : ["svg", "png", "webp", "font"]';

    DEFINE FIELD IF NOT EXISTS config.is_recommended ON TABLE icon_provider
        TYPE bool
        DEFAULT false
        COMMENT 'Fournisseur recommandé pour les nouveaux projets ?';

    DEFINE FIELD IF NOT EXISTS config.auto_import ON TABLE icon_provider
        TYPE bool
        DEFAULT false
        COMMENT 'Import automatique des nouvelles icônes de ce fournisseur ?';

-- ============================================================================
-- BLOC DOCUMENTATION : Documentation du fournisseur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS documentation ON TABLE icon_provider
    TYPE option<object>
    COMMENT 'Bloc documentation : liens et ressources';

    DEFINE FIELD IF NOT EXISTS documentation.official_url ON TABLE icon_provider
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL officielle du fournisseur';

    DEFINE FIELD IF NOT EXISTS documentation.docs_url ON TABLE icon_provider
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL de la documentation';

    DEFINE FIELD IF NOT EXISTS documentation.github_url ON TABLE icon_provider
        TYPE option<record<url>>
        REFERENCE ON DELETE REJECT
        COMMENT 'URL du repository GitHub';

    DEFINE FIELD IF NOT EXISTS documentation.npm_package ON TABLE icon_provider
        TYPE option<string>
        COMMENT 'Package NPM : lucide-react, @heroicons/react, etc.';

-- ============================================================================
-- BLOC METADATA : Métadonnées système et defaults
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_provider
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE icon_provider
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.order ON TABLE icon_provider
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Ordre d\'affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS metadata.defaults ON TABLE icon_provider
        TYPE option<object>
        COMMENT 'Valeurs par défaut pour les icônes de ce fournisseur';

        DEFINE FIELD IF NOT EXISTS metadata.defaults.viewBox ON TABLE icon_provider
            TYPE option<string>
            DEFAULT '0 0 24 24'
            COMMENT 'viewBox par défaut des icônes : "0 0 24 24"';

        DEFINE FIELD IF NOT EXISTS metadata.defaults.stroke_width ON TABLE icon_provider
            TYPE option<float>
            DEFAULT 2
            COMMENT 'Épaisseur de trait par défaut : 0.5, 1, 1.5, 2, 2.5, 3';

        DEFINE FIELD IF NOT EXISTS metadata.defaults.stroke ON TABLE icon_provider
            TYPE option<string>
            DEFAULT 'currentColor'
            COMMENT 'Couleur stroke par défaut : currentColor, #000, etc.';

        DEFINE FIELD IF NOT EXISTS metadata.defaults.fill ON TABLE icon_provider
            TYPE option<string>
            DEFAULT 'none'
            COMMENT 'Remplissage par défaut : none, currentColor, etc.';

-- ============================================================================
-- BLOC STATUS : État du fournisseur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon_provider
    TYPE object
    COMMENT 'Bloc statut : état général du fournisseur';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon_provider
        TYPE bool
        DEFAULT true
        COMMENT 'Fournisseur actif (disponible pour sélection) ?';

    DEFINE FIELD IF NOT EXISTS status.is_default ON TABLE icon_provider
        TYPE bool
        DEFAULT false
        COMMENT 'Fournisseur par défaut du système ?';

    DEFINE FIELD IF NOT EXISTS status.is_custom ON TABLE icon_provider
        TYPE bool
        DEFAULT false
        COMMENT 'Fournisseur custom Lyxal (vs fournisseur public) ?';

    DEFINE FIELD IF NOT EXISTS status.is_maintained ON TABLE icon_provider
        TYPE bool
        DEFAULT true
        COMMENT 'Fournisseur activement maintenu (updates réguliers) ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE icon_provider
        TYPE string
        ASSERT $value INSIDE ['system', 'custom', 'import']
        DEFAULT 'system'
        COMMENT 'Source du fournisseur';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon_provider
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE icon_provider
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE icon_provider
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.last_sync ON TABLE icon_provider
        TYPE option<datetime>
        COMMENT 'Date de dernière synchronisation avec la source';

DEFINE FIELD IF NOT EXISTS etag ON TABLE icon_provider
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_provider_slug ON icon_provider
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_value ON icon_provider
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_active ON icon_provider
    FIELDS status.is_active
    COMMENT 'Index sur les fournisseurs actifs';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_default ON icon_provider
    FIELDS status.is_default
    COMMENT 'Index sur le fournisseur par défaut';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_custom ON icon_provider
    FIELDS status.is_custom
    COMMENT 'Index sur les fournisseurs custom';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_maintained ON icon_provider
    FIELDS status.is_maintained
    COMMENT 'Index sur les fournisseurs maintenus';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_style ON icon_provider
    FIELDS config.style
    COMMENT 'Index sur le style des icônes';

DEFINE INDEX IF NOT EXISTS idx_icon_provider_order ON icon_provider
    FIELDS metadata.order
    COMMENT 'Index sur l\'ordre d\'affichage';
