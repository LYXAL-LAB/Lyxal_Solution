-- ============================================================================
-- Fichier : knowledge/function/gap_detection/fn_knowledge_detect_low_quality_content.surql
-- Module : knowledge
-- Fonction : fn::knowledge_gap_detect_low_quality_content()
-- Description : Détecte les contenus de faible qualité nécessitant amélioration
-- ============================================================================

DEFINE FUNCTION fn::knowledge_gap_detect_low_quality_content(
    $max_quality_score: option<number>,
    $min_feedback_negative: option<number>
) {
    -- Default values
    LET $max_quality_score = IF $max_quality_score IS NONE {0.6} ELSE {$max_quality_score};
    LET $min_feedback_negative = IF $min_feedback_negative IS NONE {2} ELSE {$min_feedback_negative};

    LET $low_quality = (
        SELECT 
            id,
            identity.slug,
            topic->identity.code AS topic_code,
            topic.domain->identity.code AS domain_code,
            metadata.quality_score,
            count((SELECT VALUE id FROM knowledge_feedback 
                   WHERE knowledge_feedback.content = knowledge_content.id 
                   AND knowledge_feedback.feedback_type IN ["negative", "correction"]
                   AND knowledge_feedback.metadata.is_active = true)) AS negative_feedback_count
        FROM knowledge_content
        WHERE metadata.is_active = true
            AND metadata.quality_score < $max_quality_score
        GROUP BY id
    );
    
    LET $gaps = (
        SELECT {
            gap_type: "low_quality_content",
            severity: IF negative_feedback_count >= $min_feedback_negative THEN "high" ELSE IF metadata.quality_score < 0.3 THEN "high" ELSE "medium" END,
            domain: topic.domain.id,
            topic: topic.id,
            content: id,
            description: "Contenu '" + identity.slug + "' a un quality_score de " + metadata.quality_score + " et " + negative_feedback_count + " feedback(s) négatif(s)",
            expected_content: "Ce contenu nécessite une amélioration de qualité (score actuel: " + metadata.quality_score + ", recommandé: >= 0.7)",
            detection_method: "automatic",
            detection_source: "detect_low_quality_content",
            detection_confidence: IF negative_feedback_count >= $min_feedback_negative THEN 0.9 ELSE 0.6 END,
            detection_detected_at: time::now(),
            resolution_status: "pending",
            metadata_priority: IF negative_feedback_count >= $min_feedback_negative THEN 4 ELSE IF metadata.quality_score < 0.3 THEN 3 ELSE 2 END,
            metadata_impact_score: IF negative_feedback_count >= $min_feedback_negative THEN 0.8 ELSE 0.6 END,
            metadata_is_active: true,
            metadata_recurrence_count: 1
        }
        FROM $low_quality
        WHERE metadata.quality_score < $max_quality_score
            OR negative_feedback_count >= $min_feedback_negative
    );
    
    RETURN {
        success: true,
        gaps_detected: array::len($gaps),
        gaps: $gaps,
        filters: {
            max_quality_score: $max_quality_score,
            min_feedback_negative: $min_feedback_negative
        },
        detected_at: time::now()
    };
};

