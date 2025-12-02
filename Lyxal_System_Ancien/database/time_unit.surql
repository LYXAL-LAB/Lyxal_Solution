-- =============================================================================================
-- |
-- | Fichier : time_unit.surql
-- | Module : System / Reference
-- | Description : Table de référence des unités de temps. Cette table centralise toutes
-- |               les unités de temps utilisables dans le système (logs, CRM, planning, etc.)
-- |               avec leurs libellés internationalisés.
-- |
-- | Dépendances :
-- |   - i18n_key
-- |   - language
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS time_unit TYPE NORMAL SCHEMAFULL
    COMMENT 'Table de référence des unités de temps avec libellés internationalisés'
    PERMISSIONS
        FOR SELECT WHERE status.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'unité de temps
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de l\'unité de temps';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE time_unit
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code unique au format UPPER_SNAKE_CASE : SECONDS, MINUTES, HOURS, DAYS, WEEKS, MONTHS, YEARS';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE time_unit
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly en lowercase-kebab-case : seconds, minutes, hours, days, weeks, months, years';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE time_unit
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Valeur technique de l\'unité (utilisée dans les calculs) : seconds, minutes, hours, days, weeks, months, years';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.label_i18n ON TABLE time_unit
        TYPE record<i18n_key>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n du libellé de l\'unité de temps (ex: "Jours", "Weeks")';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE time_unit
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n de la description de l\'unité (optionnelle)';

-- ============================================================================
-- BLOC CONTENT : Contenu et sources de traduction
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contenu : informations et sources de traduction de l\'unité';

    -- Sources de traduction pour les clés i18n
    DEFINE FIELD IF NOT EXISTS content.label_source ON TABLE time_unit
        TYPE string
        COMMENT 'Libellé source en langue par défaut (pour label_i18n)';

    DEFINE FIELD IF NOT EXISTS content.description_source ON TABLE time_unit
        TYPE option<string>
        COMMENT 'Description source en langue par défaut (pour description_i18n)';

    DEFINE FIELD IF NOT EXISTS content.langue_default ON TABLE time_unit
        TYPE record<language>
        COMMENT 'Langue source des libellés et descriptions';

-- ============================================================================
-- BLOC CONFIG : Configuration de l'unité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres de l\'unité de temps';

    DEFINE FIELD IF NOT EXISTS config.rank ON TABLE time_unit
        TYPE number
        COMMENT 'Ordre d\'affichage (1=seconds, 2=minutes, 3=hours, 4=days, 5=weeks, 6=months, 7=years)';

    DEFINE FIELD IF NOT EXISTS config.is_supported ON TABLE time_unit
        TYPE bool
        DEFAULT true
        COMMENT 'Unité supportée par le système (certaines peuvent être désactivées)';

-- ============================================================================
-- BLOC STATUS : État de l'unité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état général de l\'unité';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE time_unit
        TYPE bool
        DEFAULT true
        COMMENT 'Unité active (utilisable) ?';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE time_unit
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur de l\'unité (utilisateur ou service, défaut: "system")';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE time_unit
    TYPE object
    DEFAULT {}
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE time_unit
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE time_unit
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE time_unit
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_time_unit_code_unique ON TABLE time_unit
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code UPPERCASE';

DEFINE INDEX IF NOT EXISTS idx_time_unit_slug_unique ON TABLE time_unit
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_time_unit_value_unique ON TABLE time_unit
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur technique';

DEFINE INDEX IF NOT EXISTS idx_time_unit_active ON TABLE time_unit
    FIELDS status.is_active
    COMMENT 'Index sur les unités actives';

DEFINE INDEX IF NOT EXISTS idx_time_unit_rank ON TABLE time_unit
    FIELDS config.rank
    COMMENT 'Index sur le rang pour tri et affichage';

