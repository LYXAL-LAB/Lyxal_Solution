-- ============================================================================
-- Fichier : studio/reference/knowledge/knowledge_pack_query_example.surql
-- Module : studio/knowledge
-- Description : Exemples de requêtes pour utiliser le Knowledge Pack
-- 
-- Ce fichier contient des exemples de requêtes réutilisables pour
-- extraire la connaissance du Knowledge Pack SurrealDB.
--
-- Auteur : Équipe Lyxal (via AI Assistant)
-- Date : 2025
-- ============================================================================

-- ============================================================================
-- REQUÊTE 1 : Bundle complet d'un topic (format simple)
-- ============================================================================
-- Récupère toutes les connaissances d'un topic avec le contenu associé

SELECT 
    topic.identity.*,
    ->knowledge_pack_content AS contents
FROM knowledge_pack_topic AS topic
WHERE topic.identity.code = "DEFINE_FIELD" 
    AND topic.metadata.is_active = true
FETCH contents;

-- ============================================================================
-- REQUÊTE 2 : Bundle formaté pour IA (format structuré)
-- ============================================================================
-- Format optimisé pour génération de prompts IA

SELECT {
    topic: topic.identity.name,
    description: topic.identity.description,
    category: topic.metadata.category,
    syntax: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "syntax"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC),
    rules: (SELECT {
        title: identity.title,
        description: identity.description,
        explanation: content.explanation,
        when_to_use: content.when_to_use
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "rule"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC),
    examples_correct: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "example_correct"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC),
    examples_incorrect: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation,
        why_incorrect: content.why_incorrect
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "example_incorrect"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC),
    tips: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation,
        when_to_use: content.when_to_use
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "tip"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC),
    patterns: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation,
        when_to_use: content.when_to_use,
        tags: metadata.tags
    } FROM knowledge_pack_content 
    WHERE knowledge_pack_content.topic = topic.id 
      AND knowledge_pack_content.identity.content_type = "pattern"
      AND knowledge_pack_content.metadata.is_active = true
    ORDER BY knowledge_pack_content.metadata.priority DESC)
} FROM knowledge_pack_topic AS topic
WHERE topic.identity.code = "DEFINE_FIELD"
    AND topic.metadata.is_active = true;

-- ============================================================================
-- REQUÊTE 3 : Lister tous les topics actifs
-- ============================================================================

SELECT {
    code: identity.code,
    name: identity.name,
    description: identity.description,
    category: metadata.category,
    priority: metadata.priority
} FROM knowledge_pack_topic
WHERE metadata.is_active = true
ORDER BY metadata.category, metadata.priority DESC, identity.name;

-- ============================================================================
-- REQUÊTE 4 : Rechercher du contenu par tag
-- ============================================================================

SELECT {
    title: identity.title,
    content_type: identity.content_type,
    code: content.surql_code,
    explanation: content.explanation,
    topic_name: ->topic.identity.name
} FROM knowledge_pack_content
WHERE metadata.tags CONTAINS "validation"
    AND metadata.is_active = true
FETCH topic
ORDER BY metadata.priority DESC;

-- ============================================================================
-- REQUÊTE 5 : Obtenir seulement les patterns d'un topic
-- ============================================================================

SELECT {
    title: identity.title,
    code: content.surql_code,
    explanation: content.explanation,
    when_to_use: content.when_to_use,
    tags: metadata.tags
} FROM knowledge_pack_content
WHERE topic = knowledge_pack_topic:define_field
    AND identity.content_type = "pattern"
    AND metadata.is_active = true
ORDER BY metadata.priority DESC;

-- ============================================================================
-- REQUÊTE 6 : Statistiques d'un topic
-- ============================================================================

SELECT {
    topic: topic.identity.name,
    total_content: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.metadata.is_active = true)[0].count,
    syntax_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "syntax" AND knowledge_pack_content.metadata.is_active = true)[0].count,
    rules_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "rule" AND knowledge_pack_content.metadata.is_active = true)[0].count,
    examples_correct_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "example_correct" AND knowledge_pack_content.metadata.is_active = true)[0].count,
    examples_incorrect_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "example_incorrect" AND knowledge_pack_content.metadata.is_active = true)[0].count,
    tips_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "tip" AND knowledge_pack_content.metadata.is_active = true)[0].count,
    patterns_count: (SELECT count() FROM knowledge_pack_content WHERE knowledge_pack_content.topic = topic.id AND knowledge_pack_content.identity.content_type = "pattern" AND knowledge_pack_content.metadata.is_active = true)[0].count
} FROM knowledge_pack_topic AS topic
WHERE topic.identity.code = "DEFINE_FIELD"
    AND topic.metadata.is_active = true;

