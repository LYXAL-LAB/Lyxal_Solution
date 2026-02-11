-- =============================================================================================
-- | TABLE : i18n_config
-- | Module : i18n
-- | Description : Configuration globale du module i18n
-- |               Cette table stocke les paramètres de configuration du système i18n
-- |               et sera complétée au fur et à mesure de l'avancement du module
-- |
-- | Remarques :
-- |   - Table singleton : une seule entrée de configuration existe
-- |   - Les modifications nécessitent des permissions élevées
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_config TYPE NORMAL SCHEMAFULL
    COMMENT 'Configuration globale du module i18n'
    PERMISSIONS
        -- Lecture publique de la configuration
        FOR SELECT FULL
        -- Modification réservée aux administrateurs système
        FOR CREATE, DELETE, UPDATE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification de la configuration
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE i18n_config
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification de la configuration';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE i18n_config
        TYPE string
        DEFAULT "I18N_CONFIG"
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code unique de la configuration en UPPER_SNAKE_CASE';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE i18n_config
        TYPE string
        DEFAULT "i18n-config"
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly en lowercase-kebab-case';

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE i18n_config
        TYPE string
        DEFAULT "Configuration i18n"
        COMMENT 'Nom de la configuration';

-- ============================================================================
-- BLOC CONFIG : Paramètres de configuration du module
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE i18n_config
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc configuration : paramètres du module i18n';

    -- Langue par défaut du système
    DEFINE FIELD IF NOT EXISTS config.default_language ON TABLE i18n_config
        TYPE record<language>
        COMMENT 'Langue par défaut du système (record<language>)';

    -- Activation automatique de la langue par défaut lors de sa création
    DEFINE FIELD IF NOT EXISTS config.default_language_is_active ON TABLE i18n_config
        TYPE bool
        DEFAULT false
        COMMENT 'Active automatiquement la langue par défaut lors de sa création (via événement)';

    -- Langues autorisées (packs de langues commercialisés)
    DEFINE FIELD IF NOT EXISTS config.allowed_languages ON TABLE i18n_config
        TYPE array<record<language>>
        DEFAULT []
        COMMENT 'Liste des langues autorisées pour l\'utilisation (packs de langues commercialisés). Si vide, toutes les langues actives sont autorisées.';

    -- Langue de fallback en cas d'absence de traduction
    DEFINE FIELD IF NOT EXISTS config.fallback_language ON TABLE i18n_config
        TYPE record<language>
        COMMENT 'Langue de fallback utilisée si une traduction est absente';

    -- Comportement du fallback
    DEFINE FIELD IF NOT EXISTS config.fallback_strategy ON TABLE i18n_config
        TYPE string
        DEFAULT "key"
        ASSERT $value IN ["key", "default_language", "none"]
        COMMENT 'Stratégie de fallback : "key" (afficher la clé), "default_language" (utiliser la langue par défaut), "none" (ne rien afficher)';

    -- Support du pluriel
    DEFINE FIELD IF NOT EXISTS config.plural_support ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le support des formes plurielles';

    -- Support de l'interpolation de variables
    DEFINE FIELD IF NOT EXISTS config.interpolation_support ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le support de l\'interpolation de variables dans les traductions';

    -- Format d'interpolation par défaut
    DEFINE FIELD IF NOT EXISTS config.interpolation_format ON TABLE i18n_config
        TYPE string
        DEFAULT "mustache"
        ASSERT $value IN ["mustache", "sprintf", "icu"]
        COMMENT 'Format d\'interpolation : "mustache" ({{var}}), "sprintf" (%s), "icu" ({var})';

    -- Support des contextes de traduction
    DEFINE FIELD IF NOT EXISTS config.context_support ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le support des contextes de traduction';

    -- Support des namespaces
    DEFINE FIELD IF NOT EXISTS config.namespace_support ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le support des namespaces pour organiser les traductions';

    -- Cache des traductions
    DEFINE FIELD IF NOT EXISTS config.cache_enabled ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le cache des traductions en mémoire';

    -- Durée de vie du cache (en secondes)
    DEFINE FIELD IF NOT EXISTS config.cache_ttl ON TABLE i18n_config
        TYPE int
        DEFAULT 3600
        ASSERT $value > 0
        COMMENT 'Durée de vie du cache en secondes (Time To Live)';

    -- Validation stricte des clés
    DEFINE FIELD IF NOT EXISTS config.strict_key_validation ON TABLE i18n_config
        TYPE bool
        DEFAULT false
        COMMENT 'Active la validation stricte : erreur si une clé de traduction est absente';

    -- Support de la détection automatique de la langue
    DEFINE FIELD IF NOT EXISTS config.auto_detect_language ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active la détection automatique de la langue depuis les headers HTTP ou le navigateur';

    -- Support des variantes régionales
    DEFINE FIELD IF NOT EXISTS config.regional_variants_support ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Active le support des variantes régionales (ex: fr-FR, fr-CA, en-US, en-GB)';

-- ============================================================================
-- BLOC STATUS : État de la configuration
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE i18n_config
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc statut : état de la configuration';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE i18n_config
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si la configuration est active';

    DEFINE FIELD IF NOT EXISTS status.is_locked ON TABLE i18n_config
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si la configuration est verrouillée (empêche les modifications)';

-- ============================================================================
-- BLOC METADATA : Métadonnées de la configuration
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE i18n_config
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations sur la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE i18n_config
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création de la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE i18n_config
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de dernière modification de la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE i18n_config
        TYPE string
        DEFAULT "system"
        COMMENT 'Identifiant du créateur de la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.updated_by ON TABLE i18n_config
        TYPE string
        COMMENT 'Identifiant du dernier modificateur de la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE i18n_config
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version de la configuration (format semver)';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE i18n_config
        TYPE string
        COMMENT 'Description de la configuration';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_i18n_config_code ON TABLE i18n_config
    FIELDS identity.code
    UNIQUE
    COMMENT 'Index unique sur le code de configuration';

DEFINE INDEX IF NOT EXISTS idx_i18n_config_slug ON TABLE i18n_config
    FIELDS identity.slug
    UNIQUE
    COMMENT 'Index unique sur le slug de configuration';

DEFINE INDEX IF NOT EXISTS idx_i18n_config_active ON TABLE i18n_config
    FIELDS status.is_active
    COMMENT 'Index sur le statut actif';

-- ============================================================================
-- CONTRAINTES ET VALIDATIONS
-- ============================================================================

-- Validation : la langue par défaut et la langue de fallback doivent exister
-- (Cette validation sera effectuée au niveau applicatif car SurrealDB ne supporte pas les FOREIGN KEY)

