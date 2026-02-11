-- ============================================================================
-- TABLE : studio_page
-- Description : Définition complète d'une page dynamique (100% DB-driven)
-- Module : studio/runtime
-- ============================================================================

DEFINE TABLE studio_page SCHEMAFULL
    COMMENT 'Définition des pages dynamiques - Structure complète en JSON';

-- ============================================================================
-- IDENTITY : Identité de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc identité : identification unique de la page';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_page
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Code unique de la page (snake_case) : "contact_list", "dashboard"';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_page
        TYPE string
        COMMENT 'Slug pour URL friendly : "contact-list"';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE studio_page
        TYPE string
        DEFAULT "$before.code"
        COMMENT 'Valeur par défaut = code';

-- ============================================================================
-- PRESENTATION : Présentation de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc présentation : affichage et métadonnées';

    DEFINE FIELD IF NOT EXISTS presentation.title_i18n ON TABLE studio_page
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Titre de la page (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_page
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description de la page (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.url ON TABLE studio_page
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::starts_with($value, '/')
        COMMENT 'URL de la page : "/contacts", "/dashboard"';

    DEFINE FIELD IF NOT EXISTS presentation.layout ON TABLE studio_page
        TYPE string
        DEFAULT 'flex'
        ASSERT $value INSIDE ['flex', 'grid', 'dashboard', 'full']
        COMMENT 'Type de layout : flex, grid, dashboard, full';

    DEFINE FIELD IF NOT EXISTS presentation.breadcrumb ON TABLE studio_page
        TYPE option<array<object>>
        COMMENT 'Fil d\'Ariane : [{label: "...", url: "/..."}]';

-- ============================================================================
-- CONTENT_STRUCTURE : Structure complète de la page (100% DB-Driven)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content_structure ON TABLE studio_page
    TYPE object
    COMMENT 'Structure JSON complète de la page - RENDU 100% DB-DRIVEN';

    DEFINE FIELD IF NOT EXISTS content_structure.type ON TABLE studio_page
        TYPE string
        DEFAULT 'div'
        COMMENT 'Type de l\'élément racine : "div", "section", etc.';

    DEFINE FIELD IF NOT EXISTS content_structure.props ON TABLE studio_page
        FLEXIBLE
        TYPE option<object>
        COMMENT 'Props de l\'élément racine : {className: [...]}';

    DEFINE FIELD IF NOT EXISTS content_structure.children ON TABLE studio_page
        FLEXIBLE
        TYPE option<array<object>>
        DEFAULT []
        COMMENT 'Children : sections, composants, etc. Définit TOUT le contenu de la page';

-- ============================================================================
-- CONTEXT : Contexte d'utilisation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc contexte : contexte d\'utilisation de la page';

    DEFINE FIELD IF NOT EXISTS context.permissions ON TABLE studio_page
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Rôles autorisés : ["admin", "user"]';

    DEFINE FIELD IF NOT EXISTS context.modules ON TABLE studio_page
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Modules requis : ["crm", "sales"]';

-- ============================================================================
-- STATUS : Statut de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc statut : état de la page';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_page
        TYPE bool
        DEFAULT true
        COMMENT 'Page active ?';

    DEFINE FIELD IF NOT EXISTS status.is_system_page ON TABLE studio_page
        TYPE bool
        DEFAULT false
        COMMENT 'Page système (non modifiable) ?';

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc métadonnées : informations complémentaires';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_page
        TYPE option<string>
        COMMENT 'Notes internes sur la page';

    DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE studio_page
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Tags pour organisation : ["crm", "contacts", "list"]';

-- ============================================================================
-- TIMESTAMP : Horodatage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_page
    TYPE object
    COMMENT 'Bloc horodatage : dates de création et modification';

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_page
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création';

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_page
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de dernière modification';

-- ============================================================================
-- ETAG : Version
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_page
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour gestion de version et cache';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS code_unique ON studio_page FIELDS identity.code UNIQUE;
DEFINE INDEX IF NOT EXISTS url_unique ON studio_page FIELDS presentation.url UNIQUE;
DEFINE INDEX IF NOT EXISTS active_idx ON studio_page FIELDS status.is_active;

