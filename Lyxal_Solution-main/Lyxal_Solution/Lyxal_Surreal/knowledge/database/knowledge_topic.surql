-- ============================================================================
-- Fichier : knowledge/database/knowledge_topic.surql
-- Module : knowledge
-- TABLE : knowledge_topic
-- Description : Sujets de connaissance (ex: DEFINE FIELD, DEFINE TABLE, etc.)
-- Dépendances : knowledge_domain, knowledge_category, knowledge_sub_category, tag, knowledge_topic_keyword (relation)
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_topic TYPE NORMAL SCHEMAFULL
    COMMENT 'Sujets de connaissance rattachés à un domaine'
    PERMISSIONS
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- DOMAIN : Domaine de connaissance
-- ============================================================================
DEFINE FIELD IF NOT EXISTS domain ON TABLE knowledge_topic
    TYPE record<knowledge_domain>
    REFERENCE ON DELETE REJECT
    ASSERT $value != NONE
    COMMENT 'Référence vers le domaine auquel appartient ce topic';

-- ============================================================================
-- CATEGORIZATION : Catégorie, sous-catégorie, tags et mots-clés
-- ============================================================================
DEFINE FIELD IF NOT EXISTS category ON TABLE knowledge_topic
    TYPE record<knowledge_category>
    REFERENCE ON DELETE REJECT
    ASSERT $value != NONE
    COMMENT 'Catégorie principale du topic';

DEFINE FIELD IF NOT EXISTS sub_category ON TABLE knowledge_topic
    TYPE option<record<knowledge_sub_category>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Sous-catégorie optionnelle du topic';

DEFINE FIELD IF NOT EXISTS tags ON TABLE knowledge_topic
    TYPE option<array<record<tag>>>
    COMMENT 'Tags associés au topic (référentiel structuré global tag)';

-- NOTE: Les mots-clés libres sont gérés via la table relationnelle knowledge_topic_keyword

-- ============================================================================
-- IDENTITY : Identité + I18N keys + Slug
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_topic
    TYPE object
    COMMENT 'Bloc identité : code + slug + clés i18n';

DEFINE FIELD IF NOT EXISTS identity.code ON TABLE knowledge_topic
    TYPE string
    ASSERT $value != NONE 
        AND $value != "" 
        AND string::len($value) > 0
        AND string::uppercase($value) = $value
    COMMENT 'Code unique du topic au format UPPER_SNAKE_CASE (ex: "DEFINE_FIELD")';

DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_topic
    TYPE string
    ASSERT $value != NONE AND $value != ""
    COMMENT 'Slug lisible pour navigation/UI (ex: "define-field")';

DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE knowledge_topic
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n : nom court du topic (UI)';

DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE knowledge_topic
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n : description longue du topic';

DEFINE FIELD IF NOT EXISTS identity.ai_context_key ON TABLE knowledge_topic
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n : contexte dédié IA (optionnel)';

-- ============================================================================
-- METADATA : Métadonnées du topic
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_topic
    TYPE object
    COMMENT 'Bloc métadonnées';

DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE knowledge_topic
    TYPE string
    DEFAULT "1.0.0"
    COMMENT 'Version fonctionnelle du topic';

DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE knowledge_topic
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre d’affichage (0 par défaut)';

DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_topic
    TYPE bool
    DEFAULT true
    COMMENT 'Le topic est actif et disponible';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_topic_code ON knowledge_topic 
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code du topic';

DEFINE INDEX idx_topic_slug ON knowledge_topic 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug (UI/Navigation)';

DEFINE INDEX idx_topic_domain ON knowledge_topic 
    FIELDS domain
    COMMENT 'Index sur le domaine du topic';

DEFINE INDEX idx_topic_category ON knowledge_topic 
    FIELDS category
    COMMENT 'Index sur la catégorie principale';

DEFINE INDEX idx_topic_active ON knowledge_topic 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

DEFINE INDEX idx_topic_domain_category ON knowledge_topic 
    FIELDS domain, category
    COMMENT 'Index composite pour requêtes combinant domaine et catégorie';