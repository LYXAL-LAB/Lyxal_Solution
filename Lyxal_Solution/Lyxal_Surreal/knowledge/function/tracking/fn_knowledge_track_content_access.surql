-- ============================================================================
-- Fichier : knowledge/function/tracking/fn_knowledge_track_content_access.surql
-- Module : knowledge
-- Fonction : fn::knowledge_track_content_access()
-- Description : Fonction combinée pour tracker l'accès à un contenu (vue générale ou utilisation IA)
-- ============================================================================

DEFINE FUNCTION fn::knowledge_track_content_access(
    $content_id: record<knowledge_content>,
    $is_ai_usage: bool
) {
    -- Utilisation conditionnelle : si IA, incrémenter ai_usage_count aussi
    UPDATE $content_id SET
        metadata.analytics.ai_usage_count = IF $is_ai_usage THEN
            metadata.analytics.ai_usage_count + 1
        ELSE
            metadata.analytics.ai_usage_count
        END,
        metadata.analytics.view_count = metadata.analytics.view_count + 1,
        metadata.analytics.last_viewed = time::now();
    
    RETURN {
        success: true,
        content_id: $content_id,
        is_ai_usage: $is_ai_usage,
        analytics: {
            view_count: (SELECT VALUE metadata.analytics.view_count FROM $content_id)[0],
            ai_usage_count: (SELECT VALUE metadata.analytics.ai_usage_count FROM $content_id)[0],
            last_viewed: (SELECT VALUE metadata.analytics.last_viewed FROM $content_id)[0]
        }
    };
};

