-- ============================================================================
-- Fichier : knowledge/function/analytics/fn_knowledge_analytics_get_unused_contents.surql
-- Module : knowledge
-- Fonction : fn::knowledge_analytics_get_unused_contents()
-- Description : Récupère les contenus jamais consultés (potentiellement obsolètes)
-- ============================================================================

DEFINE FUNCTION fn::knowledge_analytics_get_unused_contents(
    $limit: option<int>,
    $domain_code: option<string>,
    $topic_code: option<string>,
    $max_quality_score: option<number>
) {
    -- Default values
    LET $limit = IF $limit IS NONE {50} ELSE {$limit};
    LET $max_quality_score = IF $max_quality_score IS NONE {1.0} ELSE {$max_quality_score};

    LET $unused_contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            type_label: identity.content_type->identity.label_key,
            topic: {
                code: topic->identity.code,
                slug: topic->identity.slug,
                label_key: topic->identity.label_key
            },
            domain: {
                code: topic.domain->identity.code,
                slug: topic.domain->identity.slug
            },
            quality_score: metadata.quality_score,
            created_at: meta::tb::id(id).timestamp
        }
        FROM knowledge_content
        WHERE metadata.is_active = true
            AND metadata.analytics.view_count = 0
            AND metadata.quality_score <= $max_quality_score
            AND (
                $domain_code IS NONE
                OR topic.domain->identity.code = $domain_code
            )
            AND (
                $topic_code IS NONE
                OR topic->identity.code = $topic_code
            )
        ORDER BY metadata.quality_score ASC, meta::tb::id(id).timestamp ASC
        LIMIT $limit
        FETCH topic, identity.content_type
    );
    
    RETURN {
        success: true,
        generated_at: time::now(),
        filters: {
            limit: $limit,
            domain_code: $domain_code,
            topic_code: $topic_code,
            max_quality_score: $max_quality_score
        },
        total_found: array::len($unused_contents),
        unused_contents: $unused_contents
    };
};

