-- ============================================================================
-- Fichier : knowledge/database/knowledge_topic_keyword.surql
-- Module : knowledge
-- TABLE : knowledge_topic_keyword (TYPE RELATION)
-- Description : Relation entre topics et mots-clés libres avec recherche full-text
-- Dépendances : knowledge_topic
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_topic_keyword TYPE RELATION SCHEMAFULL
    COMMENT 'Relation entre topics et mots-clés libres - Permet recherche full-text'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- RELATION FIELDS : in (topic) et out (keyword)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS in ON knowledge_topic_keyword
    TYPE record<knowledge_topic>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT 'Topic possédant ce mot-clé - Supprimé automatiquement si le topic est supprimé';

DEFINE FIELD IF NOT EXISTS out ON knowledge_topic_keyword
    TYPE string
    ASSERT $value != NONE 
        AND $value != "" 
        AND string::len($value) > 0
        AND string::len($value) <= 100
    COMMENT 'Mot-clé libre (normalisé en lowercase pour cohérence) - Max 100 caractères';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_keyword_text ON knowledge_topic_keyword 
    FIELDS out 
    FULLTEXT ANALYZER knowledge_keywords_analyzer BM25 HIGHLIGHTS
    COMMENT 'Index full-text pour recherche dans les mots-clés avec ranking BM25 et highlighting';

DEFINE INDEX idx_keyword_topic ON knowledge_topic_keyword 
    FIELDS in
    COMMENT 'Index sur le topic pour jointures rapides et récupération des mots-clés d un topic';

DEFINE INDEX idx_keyword_unique ON knowledge_topic_keyword 
    FIELDS in, out UNIQUE
    COMMENT 'Contrainte d unicité : un mot-clé unique par topic (évite les doublons)';

