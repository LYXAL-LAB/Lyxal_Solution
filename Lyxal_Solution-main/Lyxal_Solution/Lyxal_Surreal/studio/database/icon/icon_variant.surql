-- ============================================================================
-- TABLE : icon_variant
-- Description : Variantes d'icônes par fournisseur (mapping icon → provider → SVG)
-- Module : studio/icon
-- Type : RELATION (icon → icon_provider)
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_variant TYPE RELATION IN icon OUT icon_provider SCHEMAFULL
COMMENT 'Variantes d\'icônes spécifiques à chaque fournisseur (mapping icon → provider → SVG sur Bunny)'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la variante
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_variant
    TYPE object
    COMMENT 'Bloc identité : identification unique de la variante';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE icon_variant
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : user_profile_lucide, user_profile_heroicons';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_variant
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : user-profile-lucide, user-profile-heroicons';

-- ============================================================================
-- BLOC PROVIDER_MAPPING : Mapping avec le fournisseur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS provider_mapping ON TABLE icon_variant
    TYPE object
    COMMENT 'Bloc mapping : informations spécifiques au fournisseur';

    DEFINE FIELD IF NOT EXISTS provider_mapping.provider_icon_name ON TABLE icon_variant
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Nom de l\'icône chez le fournisseur : "user" (Lucide), "user-circle" (Heroicons)';

    DEFINE FIELD IF NOT EXISTS provider_mapping.provider_category ON TABLE icon_variant
        TYPE option<string>
        COMMENT 'Catégorie chez le fournisseur (si applicable)';

-- ============================================================================
-- BLOC ASSET : Référence vers le SVG stocké sur Bunny
-- ============================================================================

DEFINE FIELD IF NOT EXISTS asset ON TABLE icon_variant
    TYPE object
    COMMENT 'Bloc asset : référence vers le SVG sur Bunny';

    DEFINE FIELD IF NOT EXISTS asset.svg_url ON TABLE icon_variant
        TYPE record<url>
        REFERENCE ON DELETE REJECT
        VALUE type::record('url', $value)
        COMMENT 'URL du SVG sur Bunny CDN (contient viewbox, stroke_width, size_variants dans url.extensions.custom)';

    DEFINE FIELD IF NOT EXISTS asset.style_variant ON TABLE icon_variant
        TYPE string
        ASSERT $value INSIDE ['stroke', 'solid', 'duotone', 'custom']
        DEFAULT 'stroke'
        COMMENT 'Style de cette variante : stroke (outline), solid (filled), duotone, custom';

-- ============================================================================
-- BLOC STATUS : État de la variante
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon_variant
    TYPE object
    COMMENT 'Bloc statut : état général de la variante';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon_variant
        TYPE bool
        DEFAULT true
        COMMENT 'Variante active (disponible pour utilisation) ?';

    DEFINE FIELD IF NOT EXISTS status.is_fallback ON TABLE icon_variant
        TYPE bool
        DEFAULT false
        COMMENT 'Variante de fallback (utilisée si aucune autre disponible) ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE icon_variant
        TYPE string
        ASSERT $value INSIDE ['system', 'user_uploaded', 'import', 'custom']
        DEFAULT 'system'
        COMMENT 'Source de la variante';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_variant
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE icon_variant
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.quality_score ON TABLE icon_variant
        TYPE option<int>
        COMMENT 'Score de qualité (0-100) pour priorisation des variantes';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon_variant
    TYPE object
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE icon_variant
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE icon_variant
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE icon_variant
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_variant_slug ON icon_variant
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_variant_value ON icon_variant
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_icon_variant_in_out ON icon_variant
    FIELDS in, out UNIQUE
    COMMENT 'Index composite unique : un seul mapping icon→provider';

DEFINE INDEX IF NOT EXISTS idx_icon_variant_active ON icon_variant
    FIELDS status.is_active
    COMMENT 'Index sur les variantes actives';

DEFINE INDEX IF NOT EXISTS idx_icon_variant_fallback ON icon_variant
    FIELDS status.is_fallback
    COMMENT 'Index sur les variantes de fallback';

DEFINE INDEX IF NOT EXISTS idx_icon_variant_style ON icon_variant
    FIELDS asset.style_variant
    COMMENT 'Index sur le style de la variante';
