-- ============================================================================
-- TABLE : icon
-- Description : Catalogue centralisé des icônes (SVG)
-- Module : Lyxal_SVG
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue des icônes vectorielles du système'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique';

    DEFINE FIELD IF NOT EXISTS identity.pack ON TABLE icon
        TYPE record<icon_pack>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du pack source (ex: lucide, tabler, custom)';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE icon
        TYPE string
        ASSERT $value != NONE
        COMMENT 'Nom technique dans le pack (ex: arrow-right, home)';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE icon
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code technique unique (ex: LUCIDE_HOME)';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-_]+$')
        COMMENT 'Identifiant unique global URL-friendly en lowercase-kebab-case (ex: lucide-home)';

-- ============================================================================
-- BLOC RESOURCE : Données techniques SVG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS resource ON TABLE icon
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc ressource : contenu technique';

    DEFINE FIELD IF NOT EXISTS resource.content ON TABLE icon
        TYPE string
        COMMENT 'Code SVG complet et optimisé';

    DEFINE FIELD IF NOT EXISTS resource.viewbox ON TABLE icon
        TYPE string
        DEFAULT '0 0 24 24'
        COMMENT 'ViewBox standardisée';

    DEFINE FIELD IF NOT EXISTS resource.type ON TABLE icon
        TYPE string
        DEFAULT 'stroke'
        ASSERT $value INSIDE ['stroke', 'fill', 'mixed']
        COMMENT 'Type de rendu principal (stroke ou fill)';

-- ============================================================================
-- BLOC PRESENTATION : Métadonnées d'affichage et Recherche
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : infos pour UI et recherche';

    DEFINE FIELD IF NOT EXISTS presentation.label ON TABLE icon
        TYPE string
        COMMENT 'Nom lisible (ex: Arrow Right)';

    DEFINE FIELD IF NOT EXISTS presentation.tags ON TABLE icon
        TYPE array<string>
        DEFAULT []
        COMMENT 'Tags pour la recherche (ex: ["direction", "pointer"])';

    DEFINE FIELD IF NOT EXISTS presentation.category ON TABLE icon
        TYPE string
        DEFAULT 'uncategorized'
        COMMENT 'Catégorie simple (ex: ui, social, brand)';

-- ============================================================================
-- BLOC STATUS : État
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon
        TYPE bool
        DEFAULT true;

    DEFINE FIELD IF NOT EXISTS status.is_optimized ON TABLE icon
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si le SVG a passé la pipeline de normalisation';

-- ============================================================================
-- TIMESTAMPS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamps : dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE icon
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE icon
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_slug ON icon 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_lookup ON icon 
    FIELDS identity.pack, identity.name UNIQUE
    COMMENT 'Index unique sur le pack et le nom';

DEFINE INDEX IF NOT EXISTS idx_icon_search ON icon 
    FIELDS identity.name, presentation.tags, presentation.label
    COMMENT 'Index sur le nom, les tags et le label';
