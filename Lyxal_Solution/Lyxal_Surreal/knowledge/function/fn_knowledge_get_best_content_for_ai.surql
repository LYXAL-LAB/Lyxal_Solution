-- ============================================================================
-- Fichier : knowledge/function/fn_knowledge_get_best_content_for_ai.surql
-- Module : knowledge
-- Fonction : fn::knowledge_get_best_content_for_ai()
-- Description : Récupère le meilleur contenu pour un topic selon critères IA
-- ============================================================================
-- Usage avec valeurs par défaut :
--   SELECT * FROM fn::knowledge_get_best_content_for_ai(
--     "DEFINE_FIELD"
--   );
-- 
-- Usage avec paramètres personnalisés :
--   SELECT * FROM fn::knowledge_get_best_content_for_ai(
--     "DEFINE_FIELD",
--     "BEGINNER",  -- level optionnel
--     0.8  -- min_quality_score personnalisé
--   );
-- ============================================================================

DEFINE FUNCTION fn::knowledge_get_best_content_for_ai(
    $topic_code: string,
    $level: option<string>,
    $min_quality_score: option<number>
) {
    -- Default values
    LET $min_quality_score = IF $min_quality_score IS NONE {0.7} ELSE {$min_quality_score};

    LET $topic = (SELECT * FROM knowledge_topic WHERE identity.code = $topic_code AND metadata.is_active = true LIMIT 1)[0];
    LET $best_content_id = (
        SELECT id, 
            identity.content_type->metadata.ai.weight AS sort_weight,
            metadata.quality_score AS sort_quality,
            metadata.priority AS sort_priority,
            metadata.version_label AS sort_version
        FROM knowledge_content
        WHERE knowledge_content.topic = $topic.id
            AND knowledge_content.metadata.is_active = true
            AND knowledge_content.metadata.quality_score >= $min_quality_score
            AND (
                $level IS NONE
                OR knowledge_content.identity.content_type->metadata.ai.level.label = $level
            )
        ORDER BY 
            sort_weight DESC,
            sort_quality DESC,
            sort_priority DESC,
            sort_version DESC
        LIMIT 1
    )[0].id;
    LET $best_content_raw = (SELECT * FROM $best_content_id FETCH identity.content_type)[0];
    LET $best_content = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            type_label: identity.content_type->identity.label_key,
            title_key: identity.title_key,
            text_key: content.text_key,
            code: content.code,
            prompt: content.prompt,
            examples_correct: content.examples.correct,
            quality_score: metadata.quality_score,
            priority: metadata.priority,
            version_label: metadata.version_label,
            type_weight: identity.content_type->metadata.ai.weight,
            type_metadata: {
                priority: identity.content_type->metadata.ai.priority,
                weight: identity.content_type->metadata.ai.weight,
                level: identity.content_type->metadata.ai.level,
                use_cases: identity.content_type->metadata.ai.use_cases
            }
        }
        FROM $best_content_raw
        FETCH identity.content_type
    )[0];
    RETURN {
        success: true,
        topic: {
            id: $topic.id,
            code: $topic.identity.code,
            slug: $topic.identity.slug,
            label_key: $topic.identity.label_key,
            description_key: $topic.identity.description_key
        },
        best_content: $best_content,
        metadata: {
            topic_code: $topic_code,
            level: $level,
            quality_threshold: $min_quality_score,
            query_time: time::now()
        }
    };
};

