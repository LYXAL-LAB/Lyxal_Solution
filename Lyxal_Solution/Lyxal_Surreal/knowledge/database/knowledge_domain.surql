-- ============================================================================
-- Fichier : knowledge/database/knowledge_domain.surql
-- Module : knowledge
-- TABLE : knowledge_domain
-- Description : Domaines de connaissance universels (SurrealDB, Business, IA, etc.)
-- Internationalisé + enrichi pour usage UI, IA et future navigation
-- Dépendances : i18n_key, tag, icon, knowledge_domain_keyword
-- ============================================================================

DEFINE TABLE knowledge_domain TYPE NORMAL SCHEMAFULL
    COMMENT 'Domaines de connaissance universels permettant de regrouper et classer les connaissances'
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- IDENTITY : Identité du domaine + I18N + UI
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_domain
    TYPE object
    COMMENT 'Bloc identité : code, i18n et UI slug';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE knowledge_domain
        TYPE string
        ASSERT $value != NONE 
            AND $value != "" 
            AND string::len($value) > 0 
            AND string::uppercase($value) = $value
        COMMENT 'Code unique du domaine au format UPPER_SNAKE_CASE (ex: "SURREAL_DB", "BUSINESS")';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_domain
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Slug lisible pour URL / UI (ex: "surreal-db", "business", "ia")';

    DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE knowledge_domain
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : nom court du domaine (pour UI, menus, filtres)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_domain
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description longue du domaine';

    DEFINE FIELD IF NOT EXISTS identity.ai_context_key ON TABLE knowledge_domain
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : contexte explicatif pour IA. Optionnel';

-- ============================================================================
-- UI : Icône
-- ============================================================================
DEFINE FIELD IF NOT EXISTS ui ON TABLE knowledge_domain
    TYPE object
    COMMENT 'Bloc UI : icône du domaine';

    DEFINE FIELD IF NOT EXISTS ui.icon ON TABLE knowledge_domain
        TYPE option<record<icon>>
        REFERENCE ON DELETE SET NULL
        COMMENT 'Icône associée au domaine (emoji ou pictogramme via table icon)';

-- ============================================================================
-- CATEGORIZATION : Tags & Keywords
-- ============================================================================
DEFINE FIELD IF NOT EXISTS tags ON TABLE knowledge_domain
    TYPE option<array<record<tag>>>
    DEFAULT []
    COMMENT 'Tags associés au domaine provenant du référentiel tag';

-- NOTE : Mots-clés gérés via la relation knowledge_domain_keyword
-- RELATE knowledge_domain:xxx -> knowledge_domain_keyword -> "mot-clé"

-- ============================================================================
-- METADATA : Métadonnées techniques
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_domain
    TYPE object
    COMMENT 'Métadonnées techniques du domaine';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_domain
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle (différente du versioning natif SurrealDB)';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_domain
        TYPE bool
        DEFAULT true
        COMMENT 'Le domaine est actif et visible';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE knowledge_domain
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d’affichage (positif = prioritaire, négatif = secondaire)';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_domain_code ON knowledge_domain 
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code du domaine';

DEFINE INDEX idx_domain_slug ON knowledge_domain 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug pour navigation / UI / URL';

DEFINE INDEX idx_domain_active ON knowledge_domain 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif du domaine';