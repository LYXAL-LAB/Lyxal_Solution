-- ============================================================================
-- Fichier : knowledge/function/tracking/fn_knowledge_get_content_analytics.surql
-- Module : knowledge
-- Fonction : fn::knowledge_track_get_analytics()
-- Description : Récupère les métriques analytics pour un contenu de connaissance
-- ============================================================================

DEFINE FUNCTION fn::knowledge_track_get_analytics(
    $content_id: record<knowledge_content>
) {
    LET $content = (SELECT 
        id,
        identity.slug,
        metadata.analytics.view_count,
        metadata.analytics.ai_usage_count,
        metadata.analytics.last_viewed,
        metadata.quality_score,
        metadata.is_active
    FROM $content_id)[0];
    
    RETURN {
        success: true,
        content_id: $content.id,
        slug: $content.identity.slug,
        analytics: {
            view_count: $content.metadata.analytics.view_count,
            ai_usage_count: $content.metadata.analytics.ai_usage_count,
            last_viewed: $content.metadata.analytics.last_viewed,
            ai_usage_ratio: IF $content.metadata.analytics.view_count > 0 THEN
                math::round($content.metadata.analytics.ai_usage_count / $content.metadata.analytics.view_count * 100, 2)
            ELSE
                0
            END
        },
        metadata: {
            quality_score: $content.metadata.quality_score,
            is_active: $content.metadata.is_active
        }
    };
};

