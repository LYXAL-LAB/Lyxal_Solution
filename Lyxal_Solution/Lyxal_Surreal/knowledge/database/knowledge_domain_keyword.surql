-- ============================================================================
-- Fichier : knowledge/database/knowledge_domain_keyword.surql
-- Module : knowledge
-- TABLE : knowledge_domain_keyword (TYPE RELATION)
-- Description : Relation entre domaines et mots-clés libres avec recherche full-text
-- Dépendances : knowledge_domain, knowledge_keywords_analyzer
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

DEFINE TABLE knowledge_domain_keyword TYPE RELATION SCHEMAFULL
    COMMENT 'Relation entre domaines et mots-clés libres - Permet recherche full-text'
    PERMISSIONS
        FOR SELECT FULL
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- RELATION FIELDS : in (domain) et out (keyword)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS in ON knowledge_domain_keyword
    TYPE record<knowledge_domain>
    REFERENCE ON DELETE CASCADE
    ASSERT $value != NONE
    COMMENT 'Domaine possédant ce mot-clé - Supprimé automatiquement si le domaine est supprimé';

DEFINE FIELD IF NOT EXISTS out ON knowledge_domain_keyword
    TYPE string
    ASSERT $value != NONE 
        AND $value != "" 
        AND string::len($value) > 0
        AND string::len($value) <= 100
    COMMENT 'Mot-clé libre (normalisé en lowercase pour cohérence) - Max 100 caractères';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX idx_domain_keyword_text ON knowledge_domain_keyword 
    FIELDS out 
    FULLTEXT ANALYZER knowledge_keywords_analyzer BM25 HIGHLIGHTS
    COMMENT 'Index full-text pour recherche dans les mots-clés avec ranking BM25 et highlighting';

DEFINE INDEX idx_domain_keyword_domain ON knowledge_domain_keyword 
    FIELDS in
    COMMENT 'Index sur le domaine pour jointures rapides et récupération des mots-clés d un domaine';

DEFINE INDEX idx_domain_keyword_unique ON knowledge_domain_keyword 
    FIELDS in, out UNIQUE
    COMMENT 'Contrainte d unicité : un mot-clé unique par domaine (évite les doublons)';

