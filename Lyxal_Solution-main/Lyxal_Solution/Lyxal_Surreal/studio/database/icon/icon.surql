-- ============================================================================
-- TABLE : icon
-- Description : Icônes abstraites/sémantiques du système Lyxal
-- Module : studio/icon
-- ============================================================================

DEFINE TABLE IF NOT EXISTS icon TYPE NORMAL SCHEMAFULL
COMMENT 'Icônes abstraites/sémantiques utilisées dans le système Lyxal'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'icône
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE icon
    TYPE object
    COMMENT 'Bloc identité : identification unique de l\'icône';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE icon
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Valeur technique : user_profile, settings, home, arrow_right';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE icon
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly : user-profile, settings, home, arrow-right';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE icon
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE icon
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom de l\'icône (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE icon
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de l\'icône (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.label_i18n ON TABLE icon
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Label court pour boutons/UI (i18n) : "User", "Settings"';

    DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON TABLE icon
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Tooltip descriptif (i18n) : "User profile settings", "Open settings panel"';

    DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE icon
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés pour recherche : ["user", "account", "profile", "person"]';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation de l'icône
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE icon
    TYPE object
    COMMENT 'Bloc contexte : où et comment l\'icône est utilisée';

    DEFINE FIELD IF NOT EXISTS context.category ON TABLE icon
        TYPE record<icon_category>
        REFERENCE ON DELETE REJECT
        COMMENT 'Catégorie fonctionnelle de l\'icône : ui, navigation, action, status, file, brand, social, communication, media';

    DEFINE FIELD IF NOT EXISTS context.usage_hints ON TABLE icon
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Indications d\'usage : ["button", "menu", "header", "notification"]';

    DEFINE FIELD IF NOT EXISTS context.semantic_meaning ON TABLE icon
        TYPE option<string>
        COMMENT 'Signification sémantique : "Représente un utilisateur", "Indique une action d\'édition"';

-- ============================================================================
-- BLOC STATUS : État de l'icône
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE icon
    TYPE object
    COMMENT 'Bloc statut : état général de l\'icône';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE icon
        TYPE bool
        DEFAULT true
        COMMENT 'Icône active (disponible pour utilisation) ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_icon ON TABLE icon
        TYPE bool
        DEFAULT false
        COMMENT 'Icône système (fournie par défaut) ou custom ?';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE icon
        TYPE string
        ASSERT $value INSIDE ['system', 'user_created', 'import', 'custom']
        DEFAULT 'system'
        COMMENT 'Source de l\'icône';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE icon
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE icon
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE icon
        TYPE option<array<record<tag>>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Tags pour classification';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE icon
    TYPE object
    COMMENT 'Dates de création et modification';

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

DEFINE FIELD IF NOT EXISTS etag ON TABLE icon
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_icon_slug ON icon
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_icon_value ON icon
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_icon_category ON icon
    FIELDS context.category
    COMMENT 'Index sur la catégorie';

DEFINE INDEX IF NOT EXISTS idx_icon_active ON icon
    FIELDS status.is_active
    COMMENT 'Index sur les icônes actives';

DEFINE INDEX IF NOT EXISTS idx_icon_system ON icon
    FIELDS status.is_system_icon
    COMMENT 'Index sur les icônes système';
