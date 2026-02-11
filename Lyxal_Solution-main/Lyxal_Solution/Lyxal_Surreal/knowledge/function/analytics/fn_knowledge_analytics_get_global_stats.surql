-- ============================================================================
-- Fichier : knowledge/function/analytics/fn_knowledge_analytics_get_global_stats.surql
-- Module : knowledge
-- Fonction : fn::knowledge_analytics_get_global_stats()
-- Description : Récupère les statistiques globales du système de connaissance
-- ============================================================================

DEFINE FUNCTION fn::knowledge_analytics_get_global_stats() {
    -- Statistiques des domaines
    LET $total_domains = (SELECT VALUE count() FROM knowledge_domain WHERE metadata.is_active = true)[0];
    LET $total_topics = (SELECT VALUE count() FROM knowledge_topic WHERE metadata.is_active = true)[0];
    LET $total_contents = (SELECT VALUE count() FROM knowledge_content WHERE metadata.is_active = true)[0];
    
    -- Statistiques des contenus
    LET $contents_stats = (
        SELECT 
            count() AS total_contents,
            count((SELECT VALUE id WHERE metadata.analytics.view_count > 0)) AS contents_with_views,
            count((SELECT VALUE id WHERE metadata.analytics.ai_usage_count > 0)) AS contents_with_ai_usage,
            math::sum(metadata.analytics.view_count) AS total_views,
            math::sum(metadata.analytics.ai_usage_count) AS total_ai_usage,
            math::mean(metadata.quality_score) AS avg_quality_score,
            math::mean(metadata.analytics.view_count) AS avg_views_per_content
        FROM knowledge_content
        WHERE metadata.is_active = true
    )[0];
    
    -- Statistiques des topics (simplifié)
    LET $topics_total = (SELECT VALUE count() FROM knowledge_topic WHERE metadata.is_active = true)[0];
    LET $topics_with_contents = (
        SELECT VALUE count()
        FROM knowledge_topic
        WHERE metadata.is_active = true
            AND count((SELECT VALUE id FROM knowledge_content WHERE knowledge_content.topic = knowledge_topic.id AND knowledge_content.metadata.is_active = true)) > 0
    )[0];
    
    -- Contenus par type (requête simplifiée sans GROUP BY)
    LET $contents_by_type = (
        SELECT 
            identity.content_type->identity.code AS content_type,
            count() AS count
        FROM knowledge_content
        WHERE metadata.is_active = true
        GROUP BY identity.content_type->identity.code
    );
    
    -- Top 5 contenus les plus consultés
    LET $top_contents = (
        SELECT {
            id: id,
            slug: identity.slug,
            type: identity.content_type->identity.code,
            view_count: metadata.analytics.view_count,
            ai_usage_count: metadata.analytics.ai_usage_count,
            quality_score: metadata.quality_score
        }
        FROM knowledge_content
        WHERE metadata.is_active = true
        ORDER BY metadata.analytics.view_count DESC
        LIMIT 5
    );
    
    -- Contenus jamais consultés
    LET $unused_contents_count = (
        SELECT VALUE count()
        FROM knowledge_content
        WHERE metadata.is_active = true
            AND metadata.analytics.view_count = 0
    )[0];
    
    RETURN {
        success: true,
        generated_at: time::now(),
        domains: {
            total: $total_domains,
            total_topics: $total_topics,
            total_contents: $total_contents
        },
        topics: {
            total: $topics_total,
            with_contents: $topics_with_contents,
            without_contents: $topics_total - $topics_with_contents,
            avg_contents_per_topic: IF $topics_total > 0 THEN math::round($total_contents / $topics_total, 2) ELSE 0 END
        },
        contents: {
            total: $contents_stats.total_contents,
            with_views: $contents_stats.contents_with_views,
            with_ai_usage: $contents_stats.contents_with_ai_usage,
            unused: $unused_contents_count,
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
        contents_by_type: $contents_by_type,
        top_contents: $top_contents
    };
};

