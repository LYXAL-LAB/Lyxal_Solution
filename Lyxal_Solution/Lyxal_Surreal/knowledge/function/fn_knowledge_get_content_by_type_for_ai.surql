-- ============================================================================
-- Fichier : knowledge/function/fn_knowledge_get_content_by_type_for_ai.surql
-- Module : knowledge
-- Fonction : fn::knowledge_get_content_by_type_for_ai()
-- Description : Récupère les contenus d'un topic filtrés par type, optimisé IA
-- ============================================================================
-- Usage avec valeurs par défaut :
--   SELECT * FROM fn::knowledge_get_content_by_type_for_ai(
--     "DEFINE_FIELD",
--     ["SYNTAX", "EXAMPLE_CORRECT"]
--   );
-- 
-- Usage avec paramètres personnalisés :
--   SELECT * FROM fn::knowledge_get_content_by_type_for_ai(
--     "DEFINE_FIELD",
--     ["SYNTAX", "EXAMPLE_CORRECT"],
--     0.8  -- quality_threshold personnalisé
--   );
-- ============================================================================

DEFINE FUNCTION fn::knowledge_get_content_by_type_for_ai(
    $topic_code: string,
    $content_types: array<string>,
    $quality_threshold: option<number>
) {
    -- Default values
    LET $quality_threshold = IF $quality_threshold IS NONE {0.7} ELSE {$quality_threshold};

    LET $topic = (SELECT * FROM knowledge_topic WHERE identity.code = $topic_code AND metadata.is_active = true LIMIT 1)[0];
    LET $contents_sorted = (
        SELECT id,
            identity.content_type->metadata.ai.weight AS sort_weight,
            metadata.priority AS sort_priority,
            metadata.quality_score AS sort_quality
        FROM knowledge_content
        WHERE knowledge_content.topic = $topic.id
            AND knowledge_content.identity.content_type->identity.code INSIDE $content_types
            AND knowledge_content.metadata.is_active = true
            AND knowledge_content.metadata.quality_score >= $quality_threshold
        ORDER BY 
            sort_weight DESC,
            sort_priority DESC,
            sort_quality DESC
    );
    LET $contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            type_label: identity.content_type->identity.label_key,
            title_key: identity.title_key,
            description_key: identity.description_key,
            text_key: content.text_key,
            code: content.code,
            prompt: content.prompt,
            json: content.json,
            context_key: content.context_key,
            examples_correct: content.examples.correct,
            examples_incorrect: content.examples.incorrect,
            media: content.media,
            tags: tags,
            priority: metadata.priority,
            quality_score: metadata.quality_score,
            version_label: metadata.version_label,
            type_weight: identity.content_type->metadata.ai.weight,
            type_metadata: {
                priority: identity.content_type->metadata.ai.priority,
                weight: identity.content_type->metadata.ai.weight,
                level: identity.content_type->metadata.ai.level,
                use_cases: identity.content_type->metadata.ai.use_cases
            }
        }
        FROM $contents_sorted
        FETCH identity.content_type
    );
    
    -- Tracking automatique : incrémenter les compteurs pour chaque contenu retourné (utilisation IA)
    FOR $content_item IN $contents {
        LET $track_result = (SELECT * FROM fn::knowledge_track_content_access($content_item.id, true));
    };
    
    RETURN {
        success: true,
        topic: {
            id: $topic.id,
            code: $topic.identity.code,
            slug: $topic.identity.slug,
            label_key: $topic.identity.label_key
        },
        contents: $contents,
        metadata: {
            topic_code: $topic_code,
            content_types: $content_types,
            quality_threshold: $quality_threshold,
            total_found: array::len($contents),
            query_time: time::now()
        }
    };
};

