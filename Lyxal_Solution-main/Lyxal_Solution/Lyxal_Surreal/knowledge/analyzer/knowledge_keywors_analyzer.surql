-- ============================================================================
-- ANALYZER : Pour recherche full-text sur les mots-clés
-- ============================================================================

DEFINE ANALYZER IF NOT EXISTS knowledge_keywords_analyzer 
    TOKENIZERS blank, class 
    FILTERS lowercase, ascii
    COMMENT 'Analyzer pour recherche full-text dans les mots-clés (lowercase + ascii)';