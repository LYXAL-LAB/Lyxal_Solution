-- ============================================================================
-- Fichier : knowledge/function/analytics/fn_knowledge_analytics_get_top_contents.surql
-- Module : knowledge
-- Fonction : fn::knowledge_analytics_get_top_contents()
-- Description : Récupère les contenus les plus consultés avec filtres optionnels
-- ============================================================================

DEFINE FUNCTION fn::knowledge_analytics_get_top_contents(
    $limit: option<int>,
    $domain_code: option<string>,
    $topic_code: option<string>,
    $content_type: option<string>,
    $min_quality_score: option<number>
) {
    -- Default values
    LET $limit = IF $limit IS NONE {20} ELSE {$limit};
    LET $min_quality_score = IF $min_quality_score IS NONE {0.0} ELSE {$min_quality_score};

    LET $top_contents = (
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
            view_count: metadata.analytics.view_count,
            ai_usage_count: metadata.analytics.ai_usage_count,
            last_viewed: metadata.analytics.last_viewed,
            quality_score: metadata.quality_score,
            ai_usage_ratio: IF metadata.analytics.view_count > 0 THEN
                math::round(metadata.analytics.ai_usage_count / metadata.analytics.view_count * 100, 2)
            ELSE
                0
            END
        }
        FROM knowledge_content
        WHERE metadata.is_active = true
            AND metadata.quality_score >= $min_quality_score
            AND (
                $domain_code IS NONE
                OR topic.domain->identity.code = $domain_code
            )
            AND (
                $topic_code IS NONE
                OR topic->identity.code = $topic_code
            )
            AND (
                $content_type IS NONE
                OR identity.content_type->identity.code = $content_type
            )
        ORDER BY metadata.analytics.view_count DESC
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
            content_type: $content_type,
            min_quality_score: $min_quality_score
        },
        total_found: array::len($top_contents),
        top_contents: $top_contents
    };
};

