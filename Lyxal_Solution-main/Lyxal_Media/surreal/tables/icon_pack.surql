-- ============================================================================
-- TABLE : icon_pack
-- Description : Registre des bibliothèques d'icônes installées (Lucide, Tabler, etc.)
-- Module : Lyxal_SVG
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_pack TYPE NORMAL SCHEMAFULL
COMMENT 'Registre administratif des packs d\'icônes installés dans le système'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification du pack
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_pack
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité du pack';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE icon_pack
        TYPE string
        ASSERT $value != NONE
        COMMENT 'Nom technique du pack (lucide, tabler, heroicons)';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE icon_pack
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
      COMMENT 'Code technique unique du pack au format UPPER_SNAKE_CASE : ex. LUCIDE, TABLER, HEROICONS.';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_pack
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-_]+$')
      COMMENT 'Slug URL-friendly en lowercase-kebab-case : lucide, tabler, heroicons.';

    DEFINE FIELD IF NOT EXISTS identity.version ON TABLE icon_pack
        TYPE string
        DEFAULT '0.0.0'
        COMMENT 'Version de la librairie importée';

-- ============================================================================
-- BLOC INFO : Informations publiques
-- ============================================================================

DEFINE FIELD IF NOT EXISTS info ON TABLE icon_pack
    TYPE object
    DEFAULT {}
    COMMENT 'Informations descriptives';

    DEFINE FIELD IF NOT EXISTS info.category ON TABLE icon_pack
        TYPE string
        COMMENT 'Catégorie principale du pack (ex: General, Brands)';

    DEFINE FIELD IF NOT EXISTS info.tags ON TABLE icon_pack
        TYPE array
        DEFAULT []
        COMMENT 'Liste des tags descriptifs du pack';
        
    DEFINE FIELD IF NOT EXISTS info.tags.* ON TABLE icon_pack
        TYPE string;

    DEFINE FIELD IF NOT EXISTS info.license ON TABLE icon_pack
        TYPE string
        COMMENT 'Type de licence (MIT, ISC, Apache 2.0)';

    DEFINE FIELD IF NOT EXISTS info.source_url ON TABLE icon_pack
        TYPE string
        ASSERT string::is::url($value) OR $value == NONE
        COMMENT 'URL du dépôt officiel ou site web';

    DEFINE FIELD IF NOT EXISTS info.icon_count ON TABLE icon_pack
        TYPE number
        DEFAULT 0
        COMMENT 'Nombre d\'icônes contenues dans ce pack (mis à jour par script)';

-- ============================================================================
-- TIMESTAMPS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_pack
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc timestamps : dates de création et modification';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE icon_pack
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.last_sync ON TABLE icon_pack
        TYPE option<datetime>
        COMMENT 'Date de dernière synchronisation avec la source';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE icon_pack
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON TABLE icon_pack
        TYPE uuid
        READONLY
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'ETag pour optimistic locking (readonly)';

        -- Bloc analytics (métriques d'analytics du pack)
    DEFINE FIELD IF NOT EXISTS metadata.analytics ON TABLE icon_pack
       TYPE object
       DEFAULT {}
       COMMENT 'Métriques et statistiques d\'analytics du pack.';

    DEFINE FIELD IF NOT EXISTS metadata.analytics.usage_count ON TABLE icon_pack
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de téléchargements du pack (analytics).';

    
-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_pack_name ON icon_pack 
    FIELDS identity.name UNIQUE
    COMMENT 'Index unique sur le nom';