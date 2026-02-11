-- ============================================================================
-- Fichier : knowledge/function/fn_knowledge_get_topic_bundle_for_ai.surql
-- Module : knowledge
-- Fonction : fn::knowledge_get_topic_bundle_for_ai()
-- Description : Récupère un bundle complet de connaissances pour un topic, 
--               optimisé pour l'IA avec format de réponse structuré
-- ============================================================================
-- Usage avec valeurs par défaut :
--   SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
--     "DEFINE_FIELD", 
--     "GENERATE_CODE"
--   );
-- 
-- Usage avec paramètres personnalisés :
--   SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
--     "DEFINE_FIELD", 
--     "GENERATE_CODE", 
--     0.8,  -- min_quality_score personnalisé
--     20,   -- max_contents personnalisé
--     "BEGINNER"  -- level optionnel
--   );
-- ============================================================================

DEFINE FUNCTION fn::knowledge_get_topic_bundle_for_ai(
    $topic_code: string,
    $intent: string,
    $min_quality_score: option<number>,
    $max_contents: option<number>,
    $level: option<string>
) {

   -- Default values
   LET $min_quality_score = IF $min_quality_score IS NONE {0.7} ELSE {$min_quality_score};
   LET $max_contents = IF $max_contents IS NONE {10} ELSE {$max_contents};


    LET $topic = (SELECT * FROM knowledge_topic WHERE identity.code = $topic_code AND metadata.is_active = true LIMIT 1)[0];
    LET $contents_sorted = (
        SELECT id,
            identity.content_type->metadata.ai.weight AS sort_weight,
            metadata.priority AS sort_priority,
            metadata.quality_score AS sort_quality,
            metadata.version_label AS sort_version
        FROM knowledge_content
        WHERE knowledge_content.topic = $topic.id
            AND knowledge_content.metadata.is_active = true
            AND knowledge_content.metadata.quality_score >= $min_quality_score
            AND (
                $level IS NONE 
                OR knowledge_content.identity.content_type->metadata.ai.level.label = $level
            )
            AND (
                $intent IS NONE
                OR ($intent = "GENERATE_CODE" AND knowledge_content.identity.content_type->identity.code INSIDE ["SYNTAX", "RULE", "EXAMPLE_CORRECT", "PATTERN"])
                OR ($intent = "TEACH" AND knowledge_content.identity.content_type->identity.code INSIDE ["SYNTAX", "EXPLANATION", "EXAMPLE_CORRECT", "EXAMPLE_INCORRECT", "TIP"])
                OR ($intent = "VALIDATE" AND knowledge_content.identity.content_type->identity.code INSIDE ["RULE", "EXAMPLE_INCORRECT", "PATTERN"])
                OR ($intent = "QUICK_HELP" AND knowledge_content.identity.content_type->identity.code INSIDE ["TIP", "SYNTAX", "EXAMPLE_CORRECT"])
            )
        ORDER BY 
            sort_weight DESC,
            sort_priority DESC,
            sort_quality DESC,
            sort_version DESC
        LIMIT $max_contents
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
            label_key: $topic.identity.label_key,
            description_key: $topic.identity.description_key,
            ai_context_key: $topic.identity.ai_context_key,
            domain: {
                id: $topic.domain.id,
                code: $topic.domain->identity.code,
                slug: $topic.domain->identity.slug
            },
            category: {
                id: $topic.category.id,
                code: $topic.category->identity.code,
                slug: $topic.category->identity.slug
            },
            keywords: array::distinct(array::flatten((
                SELECT VALUE out.identity.value
                FROM ->knowledge_topic_keyword->out
                WHERE in = $topic.id
            )))
        },
        contents: $contents,
        metadata: {
            total_found: array::len($contents),
            quality_filtered: true,
            quality_threshold: $min_quality_score,
            max_contents: $max_contents,
            intent: $intent,
            level: $level,
            query_time: time::now()
        },
        prompt_format: {
            system: "You are an expert assistant using the Lyxal Knowledge System.",
            user: "Topic: " + $topic.identity.code + ". Intent: " + $intent + ".",
            context: "Use the following knowledge bundle to provide accurate and helpful responses."
        }
    };
};