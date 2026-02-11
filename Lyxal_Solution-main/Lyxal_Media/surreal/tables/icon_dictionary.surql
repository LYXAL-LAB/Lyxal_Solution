-- ============================================================================
-- TABLE : icon_dictionary
-- Description : Dictionnaire sémantique des icônes Lyxal (Abstraction)
-- Module : Lyxal_SVG
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon_dictionary TYPE NORMAL SCHEMAFULL
COMMENT 'Dictionnaire sémantique faisant le lien entre un concept métier et une icône technique'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Le Concept Métier
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon_dictionary
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : le concept abstrait';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE icon_dictionary
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
      COMMENT 'Code technique unique de la clé au format UPPER_SNAKE_CASE : ex. USER_PROFILE, ACTION_SAVE, NAV_HOME.';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon_dictionary
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-_]+$')
      COMMENT 'Slug URL-friendly en lowercase-kebab-case : user-profile, action-save, nav-home.';

-- ============================================================================
-- BLOC PRESENTATION : Affichage & Internationalisation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon_dictionary
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : humainement lisible';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE icon_dictionary
        TYPE option<string>
        COMMENT 'Clé de traduction pour le nom (ex: i18n_icon_user_profile_name)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE icon_dictionary
        TYPE option<string>
        COMMENT 'Clé de traduction pour la description';

    DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE icon_dictionary
        TYPE array<string>
        DEFAULT []
        COMMENT 'Mots-clés métier supplémentaires';

-- ============================================================================
-- BLOC POINTER : Le lien vers la technique
-- ============================================================================

DEFINE FIELD IF NOT EXISTS pointer ON TABLE icon_dictionary
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc pointeur : lien vers l\'asset technique';

    DEFINE FIELD IF NOT EXISTS pointer.default_icon ON TABLE icon_dictionary
        TYPE option<record<icon>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Référence vers l\'icône technique par défaut';

    DEFINE FIELD IF NOT EXISTS pointer.fallback_icon ON TABLE icon_dictionary
        TYPE option<record<icon>>
        REFERENCE ON DELETE UNSET
        COMMENT 'Icône de secours si la principale échoue';

-- ============================================================================
-- METADATA
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon_dictionary
    TYPE object
    DEFAULT {};

    -- Bloc timestamp (dates de création et modification)
    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE icon_dictionary
        TYPE datetime
        READONLY
        DEFAULT time::now();

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE icon_dictionary
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now();

    DEFINE FIELD IF NOT EXISTS metadata.etag ON TABLE icon_dictionary
        TYPE uuid
        READONLY
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'ETag pour contrôle optimiste (version).';

    -- Bloc analytics (métriques d'utilisation)
    DEFINE FIELD IF NOT EXISTS metadata.analytics ON TABLE icon_dictionary
       TYPE object
       COMMENT 'Métriques et statistiques d\'utilisation de l\'icône.';

    DEFINE FIELD IF NOT EXISTS metadata.analytics.usage_count ON TABLE icon_dictionary
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre d\'utilisations de l\'icône (analytics).';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_dictionary_slug ON icon_dictionary 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';