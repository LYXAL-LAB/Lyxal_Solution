-- =============================================================================================
-- |
-- | Fichier : error_code.surql
-- | Module : error / error_code
-- | Description : Registre immuable des codes d'erreur. Géré via les déploiements (seeds),
-- |               non modifiable par l'application.
-- |               Refactorisé selon les conventions modulaires Lyxal.
-- |
-- | Dépendances :
-- |   - error_severity
-- |   - i18n_key
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS error_code TYPE NORMAL SCHEMAFULL
    COMMENT 'Registre immuable des codes d\'erreur'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du code d'erreur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du code d\'erreur';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE error_code
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code unique au format UPPER_SNAKE_CASE : USER_NOT_FOUND, INVALID_CREDENTIALS';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE error_code
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly en lowercase-kebab-case : user-not-found, invalid-credentials';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE error_code
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0
        COMMENT 'Valeur technique du code d\'erreur (identique au code en lowercase)';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.label_i18n ON TABLE error_code
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n du libellé du code d\'erreur (optionnelle)';

    DEFINE FIELD IF NOT EXISTS presentation.message_i18n ON TABLE error_code
        TYPE record<i18n_key>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Clé i18n associée au message principal';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE error_code
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Description lisible du code (documentation technique)';

-- ============================================================================
-- BLOC CONTENT : Contenu et relations du code d'erreur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc contenu : relations et informations du code d\'erreur';

    DEFINE FIELD IF NOT EXISTS content.severity ON TABLE error_code
        TYPE record<error_severity>
        REFERENCE ON DELETE CASCADE
        COMMENT 'Sévérité associée au code d\'erreur';

    DEFINE FIELD IF NOT EXISTS content.payload ON TABLE error_code
        TYPE option<object>
        FLEXIBLE
        DEFAULT {}
        COMMENT 'Informations complémentaires (données contextuelles, paramètres, etc.)';

    -- Sources de traduction pour les clés i18n
    DEFINE FIELD IF NOT EXISTS content.label_source ON TABLE error_code
        TYPE option<string>
        COMMENT 'Libellé source en langue par défaut (pour label_i18n)';

    DEFINE FIELD IF NOT EXISTS content.message_source ON TABLE error_code
        TYPE string
        COMMENT 'Message source en langue par défaut (pour message_i18n)';

    DEFINE FIELD IF NOT EXISTS content.description_source ON TABLE error_code
        TYPE option<string>
        COMMENT 'Description source en langue par défaut (pour description_i18n)';

    DEFINE FIELD IF NOT EXISTS content.langue_default ON TABLE error_code
        TYPE record<language>
        COMMENT 'Langue source des messages et descriptions';

-- ============================================================================
-- BLOC CONFIG : Configuration du code d'erreur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres du code d\'erreur';

    DEFINE FIELD IF NOT EXISTS config.success_result ON TABLE error_code
        TYPE bool
        COMMENT 'Résultat booléen dérivé de severity (true si succès, false si erreur)';

-- ============================================================================
-- BLOC STATUS : État du code d'erreur
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état général du code d\'erreur';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE error_code
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur du code d\'erreur (utilisateur ou service, défaut: "system")';

    DEFINE FIELD IF NOT EXISTS metadata.category ON TABLE error_code
        TYPE option<string>
        COMMENT 'Catégorie du code d\'erreur (ex: authentication, validation, system)';

    DEFINE FIELD IF NOT EXISTS metadata.recommended_action ON TABLE error_code
        TYPE option<string>
        COMMENT 'Action recommandée pour résoudre l\'erreur';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE error_code
    TYPE object
    DEFAULT {}
    COMMENT 'Dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE error_code
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE error_code
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE error_code
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_error_code_code_unique ON TABLE error_code
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code UPPERCASE';

DEFINE INDEX IF NOT EXISTS idx_error_code_slug_unique ON TABLE error_code
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_error_code_value_unique ON TABLE error_code
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_error_code_severity ON TABLE error_code
    FIELDS content.severity
    COMMENT 'Index sur la sévérité pour filtrage';

DEFINE INDEX IF NOT EXISTS idx_error_code_success_result ON TABLE error_code
    FIELDS config.success_result
    COMMENT 'Index sur le résultat de succès pour filtrage';

DEFINE INDEX IF NOT EXISTS idx_error_code_category ON TABLE error_code
    FIELDS metadata.category
    COMMENT 'Index sur la catégorie pour filtrage';
