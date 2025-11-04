-- ============================================================================
-- Fichier : knowledge/function/analytics/fn_knowledge_analytics_get_domain_stats.surql
-- Module : knowledge
-- Fonction : fn::knowledge_analytics_get_domain_stats()
-- Description : Récupère les statistiques détaillées pour un domaine spécifique
-- ============================================================================

DEFINE FUNCTION fn::knowledge_analytics_get_domain_stats(
    $domain_code: string
) {
    LET $domain = (SELECT * FROM knowledge_domain WHERE identity.code = $domain_code AND metadata.is_active = true LIMIT 1)[0];
    
    IF $domain = NONE {
        RETURN {
            success: false,
            error: "Domain not found",
            domain_code: $domain_code
        };
    };
    
    -- Statistiques des topics du domaine (simplifié)
    LET $topics_total = (SELECT VALUE count() FROM knowledge_topic WHERE domain = $domain.id AND metadata.is_active = true)[0];
    LET $topics_with_contents = (
        SELECT VALUE count()
        FROM knowledge_topic
        WHERE domain = $domain.id
            AND metadata.is_active = true
            AND count((SELECT VALUE id FROM knowledge_content WHERE knowledge_content.topic = knowledge_topic.id AND knowledge_content.metadata.is_active = true)) > 0
    )[0];
    
    -- Statistiques des contenus du domaine
    LET $contents_stats = (
        SELECT 
            count() AS total_contents,
            count((SELECT VALUE id WHERE metadata.analytics.view_count > 0)) AS contents_with_views,
            count((SELECT VALUE id WHERE metadata.analytics.ai_usage_count > 0)) AS contents_with_ai_usage,
            count((SELECT VALUE id WHERE metadata.analytics.view_count = 0)) AS unused_contents,
            math::sum(metadata.analytics.view_count) AS total_views,
            math::sum(metadata.analytics.ai_usage_count) AS total_ai_usage,
            math::mean(metadata.quality_score) AS avg_quality_score,
            math::mean(metadata.analytics.view_count) AS avg_views_per_content
        FROM knowledge_content
        WHERE topic.domain = $domain.id
            AND metadata.is_active = true
    )[0];
    
    -- Topics avec le plus de contenus (simplifié)
    LET $top_topics = (
        SELECT {
            id: id,
            code: identity.code,
            slug: identity.slug,
            contents_count: count((SELECT VALUE id FROM knowledge_content WHERE knowledge_content.topic = knowledge_topic.id AND knowledge_content.metadata.is_active = true))
        }
        FROM knowledge_topic
        WHERE domain = $domain.id
            AND metadata.is_active = true
        ORDER BY contents_count DESC
        LIMIT 10
    );
    
    -- Contenus par type dans le domaine (simplifié)
    LET $contents_by_type = (
        SELECT 
            identity.content_type->identity.code AS content_type,
            count() AS count
        FROM knowledge_content
        WHERE topic.domain = $domain.id
            AND metadata.is_active = true
        GROUP BY identity.content_type->identity.code
    );
    
    -- Top contenus du domaine
    LET $top_contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            topic: topic->identity.code,
            view_count: metadata.analytics.view_count,
            ai_usage_count: metadata.analytics.ai_usage_count,
            quality_score: metadata.quality_score
        }
        FROM knowledge_content
        WHERE topic.domain = $domain.id
            AND metadata.is_active = true
        ORDER BY metadata.analytics.view_count DESC
        LIMIT 10
    );
    
    RETURN {
        success: true,
        domain: {
            id: $domain.id,
            code: $domain.identity.code,
            slug: $domain.identity.slug,
            label_key: $domain.identity.label_key
        },
        generated_at: time::now(),
        topics: {
            total: $topics_total,
            with_contents: $topics_with_contents,
            without_contents: $topics_total - $topics_with_contents,
            avg_contents_per_topic: IF $topics_total > 0 THEN math::round($contents_stats.total_contents / $topics_total, 2) ELSE 0 END
        },
        contents: {
            total: $contents_stats.total_contents,
            with_views: $contents_stats.contents_with_views,
            with_ai_usage: $contents_stats.contents_with_ai_usage,
            unused: $contents_stats.unused_contents,
            total_views: $contents_stats.total_views,
            total_ai_usage: $contents_stats.total_ai_usage,
            avg_quality_score: $contents_stats.avg_quality_score,
            avg_views_per_content: $contents_stats.avg_views_per_content,
            ai_usage_ratio: IF $contents_stats.total_views > 0 THEN
                math::round($contents_stats.total_ai_usage / $contents_stats.total_views * 100, 2)
            ELSE
                0
            END
        },
        top_topics: $top_topics,
        contents_by_type: $contents_by_type,
        top_contents: $top_contents
    };
};

