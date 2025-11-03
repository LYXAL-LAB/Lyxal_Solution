-- ============================================================================
-- Fichier : knowledge/function/tracking/fn_knowledge_track_ai_usage.surql
-- Module : knowledge
-- Fonction : fn::knowledge_track_ai_usage()
-- Description : Incrémente le compteur d'utilisation IA pour un contenu de connaissance
-- ============================================================================

DEFINE FUNCTION fn::knowledge_track_ai_usage(
    $content_id: record<knowledge_content>
) {
    UPDATE $content_id SET
        metadata.analytics.ai_usage_count = metadata.analytics.ai_usage_count + 1,
        metadata.analytics.view_count = metadata.analytics.view_count + 1,
        metadata.analytics.last_viewed = time::now();
    
    RETURN {
        success: true,
        content_id: $content_id,
        analytics: {
            view_count: (SELECT VALUE metadata.analytics.view_count FROM $content_id)[0],
            ai_usage_count: (SELECT VALUE metadata.analytics.ai_usage_count FROM $content_id)[0],
            last_viewed: (SELECT VALUE metadata.analytics.last_viewed FROM $content_id)[0]
        }
    };
};

