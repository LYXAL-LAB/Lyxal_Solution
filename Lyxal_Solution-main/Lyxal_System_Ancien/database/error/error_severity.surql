-- =============================================================================================
-- |
-- | Fichier : error_severity.surql
-- | Module : error / error_severity
-- | Description : Dictionnaire immuable des sévérités d'erreur. Cette table est gérée
-- |               comme du code ; toute modification doit passer par un fichier de
-- |               migration .surql et un déploiement contrôlé.
-- |               Refactorisé selon les conventions modulaires Lyxal.
-- |
-- | Dépendances :
-- |   - i18n_key
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS error_severity TYPE NORMAL SCHEMAFULL
    COMMENT 'Dictionnaire immuable des sévérités d\'erreur'
    PERMISSIONS
        FOR SELECT WHERE status.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la sévérité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de la sévérité';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE error_severity
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code unique au format UPPER_SNAKE_CASE : INFO, WARNING, ERROR, CRITICAL';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE error_severity
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly en lowercase-kebab-case : info, warning, error, critical';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE error_severity
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Valeur technique de la sévérité (identique au code en lowercase)';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.label_i18n ON TABLE error_severity
        TYPE record<i18n_key>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n du libellé de la sévérité';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE error_severity
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n de la description de la sévérité (optionnelle)';

    DEFINE FIELD IF NOT EXISTS presentation.message_i18n ON TABLE error_severity
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n pour un message générique lié à la sévérité (optionnelle)';

-- ============================================================================
-- BLOC CONTENT : Contenu et sources de traduction de la sévérité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contenu : informations et sources de traduction de la sévérité';

    -- Sources de traduction pour les clés i18n
    DEFINE FIELD IF NOT EXISTS content.label_source ON TABLE error_severity
        TYPE string
        COMMENT 'Libellé source en langue par défaut (pour label_i18n)';

    DEFINE FIELD IF NOT EXISTS content.description_source ON TABLE error_severity
        TYPE option<string>
        COMMENT 'Description source en langue par défaut (pour description_i18n)';

    DEFINE FIELD IF NOT EXISTS content.message_source ON TABLE error_severity
        TYPE option<string>
        COMMENT 'Message source en langue par défaut (pour message_i18n)';

    DEFINE FIELD IF NOT EXISTS content.langue_default ON TABLE error_severity
        TYPE record<language>
        COMMENT 'Langue source des libellés, descriptions et messages';

-- ============================================================================
-- BLOC CONFIG : Configuration de la sévérité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres de la sévérité';

    DEFINE FIELD IF NOT EXISTS config.rank ON TABLE error_severity
        TYPE number
        COMMENT 'Poids numérique pour ordonner et comparer les niveaux de sévérité (ex: info=20, error=40)';

-- ============================================================================
-- BLOC STATUS : État de la sévérité
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état général de la sévérité';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE error_severity
        TYPE bool
        DEFAULT true
        COMMENT 'Sévérité active (utilisable) ?';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE error_severity
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur de la sévérité (utilisateur ou service, défaut: "system")';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE error_severity
    TYPE object
    DEFAULT {}
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE error_severity
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE error_severity
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE error_severity
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_error_severity_code_unique ON TABLE error_severity
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code UPPERCASE';

DEFINE INDEX IF NOT EXISTS idx_error_severity_slug_unique ON TABLE error_severity
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_error_severity_value_unique ON TABLE error_severity
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_error_severity_active ON TABLE error_severity
    FIELDS status.is_active
    COMMENT 'Index sur les sévérités actives';

DEFINE INDEX IF NOT EXISTS idx_error_severity_rank ON TABLE error_severity
    FIELDS config.rank
    COMMENT 'Index sur le rang pour tri et comparaison';
