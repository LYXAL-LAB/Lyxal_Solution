-- ============================================================================
-- Fichier : knowledge/function/gap_detection/fn_knowledge_record_gap.surql
-- Module : knowledge
-- Fonction : fn::knowledge_gap_record_gap()
-- Description : Enregistre un gap détecté dans la table knowledge_gap
-- ============================================================================

DEFINE FUNCTION fn::knowledge_gap_record_gap(
    $gap_type: string,
    $severity: string,
    $domain: option<record<knowledge_domain>>,
    $topic: option<record<knowledge_topic>>,
    $content: option<record<knowledge_content>>,
    $description: option<string>,
    $expected_content: option<string>,
    $suggested_keywords: option<array<string>>,
    $detection_method: string,
    $detection_source: option<string>,
    $confidence: number,
    $priority: int,
    $impact_score: number
) {
    -- Vérifier si un gap similaire existe déjà et le mettre à jour
    LET $existing_gap = (
        SELECT id, metadata.recurrence_count
        FROM knowledge_gap
        WHERE gap_type = $gap_type
            AND severity = $severity
            AND domain = $domain
            AND topic = $topic
            AND content = $content
            AND resolution.status = "pending"
            AND metadata.is_active = true
        LIMIT 1
    )[0];
    
    IF $existing_gap != NONE {
        UPDATE $existing_gap.id SET
            metadata.recurrence_count = $existing_gap.metadata.recurrence_count + 1,
            detection.detected_at = time::now();
        
        RETURN {
            success: true,
            action: "updated",
            gap_id: $existing_gap.id,
            recurrence_count: $existing_gap.metadata.recurrence_count + 1
        };
    } ELSE {
        LET $new_gap = CREATE knowledge_gap SET
            gap_type = $gap_type,
            severity = $severity,
            domain = $domain,
            topic = $topic,
            content = $content,
            description = $description,
            expected_content = $expected_content,
            suggested_keywords = $suggested_keywords,
            detection.method = $detection_method,
            detection.source = $detection_source,
            detection.detected_at = time::now(),
            detection.confidence = $confidence,
            resolution.status = "pending",
            metadata.priority = $priority,
            metadata.impact_score = $impact_score,
            metadata.is_active = true,
            metadata.recurrence_count = 1;
        
        RETURN {
            success: true,
            action: "created",
            gap_id: $new_gap[0].id,
            recurrence_count: 1
        };
    };
};
