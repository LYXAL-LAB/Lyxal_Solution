-- ============================================================================
-- Fichier : knowledge/function/analytics/fn_knowledge_analytics_get_topic_stats.surql
-- Module : knowledge
-- Fonction : fn::knowledge_analytics_get_topic_stats()
-- Description : Récupère les statistiques détaillées pour un topic spécifique
-- ============================================================================

DEFINE FUNCTION fn::knowledge_analytics_get_topic_stats(
    $topic_code: string
) {
    LET $topic = (SELECT * FROM knowledge_topic WHERE identity.code = $topic_code AND metadata.is_active = true LIMIT 1)[0];
    
    IF $topic = NONE {
        RETURN {
            success: false,
            error: "Topic not found",
            topic_code: $topic_code
        };
    };
    
    -- Statistiques des contenus du topic
    LET $contents_stats = (
        SELECT 
            count() AS total_contents,
            count((SELECT VALUE id WHERE metadata.analytics.view_count > 0)) AS contents_with_views,
            count((SELECT VALUE id WHERE metadata.analytics.ai_usage_count > 0)) AS contents_with_ai_usage,
            count((SELECT VALUE id WHERE metadata.analytics.view_count = 0)) AS unused_contents,
            math::sum(metadata.analytics.view_count) AS total_views,
            math::sum(metadata.analytics.ai_usage_count) AS total_ai_usage,
            math::mean(metadata.quality_score) AS avg_quality_score,
            math::mean(metadata.analytics.view_count) AS avg_views_per_content,
            math::max(metadata.quality_score) AS max_quality_score,
            math::min(metadata.quality_score) AS min_quality_score
        FROM knowledge_content
        WHERE topic = $topic.id
            AND metadata.is_active = true
    )[0];
    
    -- Contenus par type dans le topic (simplifié)
    LET $contents_by_type = (
        SELECT 
            identity.content_type->identity.code AS content_type,
            count() AS count
        FROM knowledge_content
        WHERE topic = $topic.id
            AND metadata.is_active = true
        GROUP BY identity.content_type->identity.code
    );
    
    -- Top contenus du topic
    LET $top_contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            type_label: identity.content_type->identity.label_key,
            view_count: metadata.analytics.view_count,
            ai_usage_count: metadata.analytics.ai_usage_count,
            quality_score: metadata.quality_score,
            last_viewed: metadata.analytics.last_viewed
        }
        FROM knowledge_content
        WHERE topic = $topic.id
            AND metadata.is_active = true
        ORDER BY metadata.analytics.view_count DESC
        LIMIT 10
        FETCH identity.content_type
    );
    
    -- Contenus jamais consultés
    LET $unused_contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            quality_score: metadata.quality_score
        }
        FROM knowledge_content
        WHERE topic = $topic.id
            AND metadata.is_active = true
            AND metadata.analytics.view_count = 0
        ORDER BY metadata.quality_score DESC
        LIMIT 10
    );
    
    RETURN {
        success: true,
        topic: {
            id: $topic.id,
            code: $topic.identity.code,
            slug: $topic.identity.slug,
            label_key: $topic.identity.label_key,
            domain: {
                code: $topic.domain->identity.code,
                slug: $topic.domain->identity.slug
            }
        },
        generated_at: time::now(),
        contents: {
            total: $contents_stats.total_contents,
            with_views: $contents_stats.contents_with_views,
            with_ai_usage: $contents_stats.contents_with_ai_usage,
            unused: $contents_stats.unused_contents,
            total_views: $contents_stats.total_views,
            total_ai_usage: $contents_stats.total_ai_usage,
            avg_quality_score: $contents_stats.avg_quality_score,
            avg_views_per_content: $contents_stats.avg_views_per_content,
            max_quality_score: $contents_stats.max_quality_score,
            min_quality_score: $contents_stats.min_quality_score,
            ai_usage_ratio: IF $contents_stats.total_views > 0 THEN
                math::round($contents_stats.total_ai_usage / $contents_stats.total_views * 100, 2)
            ELSE
                0
            END
        },
        contents_by_type: $contents_by_type,
        top_contents: $top_contents,
        unused_contents: $unused_contents
    };
};

