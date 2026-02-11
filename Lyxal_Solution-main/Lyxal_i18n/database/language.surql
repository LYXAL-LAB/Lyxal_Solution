-- =============================================================================================
-- | TABLE : language
-- | Module : i18n
-- | Description : Dictionnaire semi-géré des langues supportées (ISO 639-1)
-- |               Refactorisé selon les conventions Lyxal
-- |
-- | Remarques :
-- |   - Le catalogue des langues est géré par migration (pas de create/delete).
-- |   - L'état d'activation est géré par l'application via des fonctions dédiées.
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS language TYPE NORMAL SCHEMAFULL
    COMMENT 'Dictionnaire semi-géré des langues supportées (ISO 639-1)'
    PERMISSIONS
        -- Tout le monde peut lire les langues actives
        FOR SELECT WHERE metadata.status.is_active = true
        -- Personne ne peut créer ou supprimer de langues
        FOR CREATE, DELETE, UPDATE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de la langue
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE language
    TYPE object
    COMMENT 'Bloc identité : identification unique de la langue';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE language
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
        COMMENT 'Code unique au format UPPER_SNAKE_CASE : FR, EN, ES, etc.';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE language
        TYPE string
        ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly en lowercase : fr, en, es (code ISO 639-1)';

-- ============================================================================
-- BLOC CONTENT : Contenu et informations de la langue
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE language
    TYPE object
    COMMENT 'Bloc contenu : informations sur la langue';

    DEFINE FIELD IF NOT EXISTS content.name ON TABLE language
        TYPE string
        COMMENT 'Nom de la langue en anglais (ex: French, English)';

    DEFINE FIELD IF NOT EXISTS content.native_name ON TABLE language
        TYPE string
        COMMENT 'Nom natif de la langue (ex: Français, English)';

    DEFINE FIELD IF NOT EXISTS content.direction ON TABLE language
        TYPE string
        ASSERT $value == NONE OR $value IN ['ltr', 'rtl']
        COMMENT 'Direction d\'écriture : ltr (left-to-right) ou rtl (right-to-left)';

    DEFINE FIELD IF NOT EXISTS content.snowball_supported ON TABLE language
        TYPE bool
        DEFAULT false
        COMMENT 'Support de stemmer Snowball (pour analyzers Surreal)';

    DEFINE FIELD IF NOT EXISTS content.icon_flag ON TABLE language
        TYPE option<record<icon>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Référence vers l\'asset du drapeau (table icon)';

    DEFINE FIELD IF NOT EXISTS content.name_i18n ON TABLE language
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n partagée pour le libellé de langue (évite duplication)';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE language
    TYPE object
    DEFAULT {}
    COMMENT 'Métadonnées de création, audit et cycle de vie de la langue';

    -- Métadonnées principales (création et audit)
    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE language
        TYPE option<string>
        DEFAULT "system"
        COMMENT 'Identifiant du créateur de la langue (utilisateur ou service, défaut: "system")';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE language
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création de la langue';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE language
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON TABLE language
        TYPE uuid
        READONLY
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'ETag pour contrôle optimiste (version)';

    -- Bloc statut (cycle de vie de la langue)
    DEFINE FIELD IF NOT EXISTS metadata.status ON TABLE language
        TYPE object
        DEFAULT {}
        COMMENT 'Statut et cycle de vie de la langue';

        DEFINE FIELD IF NOT EXISTS metadata.status.is_active ON TABLE language
            TYPE bool
            DEFAULT false
            COMMENT 'Langue active (disponible pour utilisation)';

    -- Bloc analytics (métriques d'utilisation)
    DEFINE FIELD IF NOT EXISTS metadata.analytics ON TABLE language
        TYPE object
        DEFAULT {}
        COMMENT 'Métriques et statistiques d\'utilisation de la langue';

        DEFINE FIELD IF NOT EXISTS metadata.analytics.usage_count ON TABLE language
            TYPE int
            DEFAULT 0
            COMMENT 'Nombre d\'utilisations de la langue (analytics)';

        DEFINE FIELD IF NOT EXISTS metadata.analytics.last_used_at ON TABLE language
            TYPE option<datetime>
            COMMENT 'Date de dernière utilisation de la langue (lors de la sélection dans l\'application)';

-- ============================================================================
-- INDEX
-- ============================================================================

-- Index unique sur le code (UPPERCASE)
DEFINE INDEX IF NOT EXISTS idx_language_code_unique
    ON TABLE language
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code UPPERCASE';

-- Index unique sur le slug (code ISO lowercase)
DEFINE INDEX IF NOT EXISTS idx_language_slug_unique
    ON TABLE language
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug (code ISO 639-1)';

-- Index sur le nom (pour recherche)
DEFINE INDEX IF NOT EXISTS idx_language_name
    ON TABLE language
    FIELDS content.name
    COMMENT 'Index sur le nom de la langue';

-- Index sur le statut actif (pour requêtes fréquentes)
DEFINE INDEX IF NOT EXISTS idx_language_active
    ON TABLE language
    FIELDS metadata.status.is_active
    COMMENT 'Index sur les langues actives';