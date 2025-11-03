-- ============================================================================
-- Fichier : knowledge/database/knowledge_keyword.surql
-- Module : knowledge
-- TABLE : knowledge_keyword
-- Description : Référentiel des mots-clés utilisés pour recherche full-text
-- Dépendances : knowledge_keywords_analyzer
-- ============================================================================

DEFINE TABLE knowledge_keyword TYPE NORMAL SCHEMAFULL
    COMMENT 'Référentiel des mots-clés utilisés pour recherche full-text dans le système knowledge'
    PERMISSIONS 
        FOR SELECT FULL
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- IDENTITY : Identité du mot-clé
-- ============================================================================
DEFINE FIELD IF NOT EXISTS identity ON TABLE knowledge_keyword
    TYPE object
    COMMENT 'Bloc identité du mot-clé';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE knowledge_keyword
        TYPE string
        ASSERT $value != NONE 
            AND $value != "" 
            AND string::len($value) > 0
            AND string::len($value) <= 100
            AND string::lowercase($value) = $value
        COMMENT 'Valeur du mot-clé en lowercase (normalisé) - Max 100 caractères';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE knowledge_keyword
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Slug du mot-clé (pour URL et référence)';

-- ============================================================================
-- METADATA : Métadonnées du mot-clé
-- ============================================================================
DEFINE FIELD IF NOT EXISTS metadata ON TABLE knowledge_keyword
    TYPE object
    COMMENT 'Métadonnées du mot-clé';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE knowledge_keyword
        TYPE bool
        DEFAULT true
        COMMENT 'Le mot-clé est actif et peut être utilisé';

    DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE knowledge_keyword
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de fois que ce mot-clé est utilisé (domaines + topics)';

-- ============================================================================
-- INDEXES
-- ============================================================================
DEFINE INDEX idx_keyword_value ON knowledge_keyword 
    FIELDS identity.value UNIQUE
    COMMENT 'Index unique sur la valeur du mot-clé';

DEFINE INDEX idx_keyword_slug ON knowledge_keyword 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX idx_keyword_search ON knowledge_keyword 
    FIELDS identity.value 
    SEARCH ANALYZER knowledge_keywords_analyzer
    COMMENT 'Index full-text pour recherche dans les mots-clés avec ranking BM25';

DEFINE INDEX idx_keyword_active ON knowledge_keyword 
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

