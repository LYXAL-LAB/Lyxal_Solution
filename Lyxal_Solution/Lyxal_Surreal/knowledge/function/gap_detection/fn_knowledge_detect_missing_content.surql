-- ============================================================================
-- Fichier : knowledge/function/gap_detection/fn_knowledge_detect_missing_content.surql
-- Module : knowledge
-- Fonction : fn::knowledge_gap_detect_missing_content()
-- Description : Détecte les topics avec peu ou pas de contenus de haute qualité
-- ============================================================================

DEFINE FUNCTION fn::knowledge_gap_detect_missing_content(
    $domain_code: option<string>,
    $min_content_count: option<number>,
    $min_quality_score: option<number>
) {
    -- Default values
    LET $min_content_count = IF $min_content_count IS NONE {3} ELSE {$min_content_count};
    LET $min_quality_score = IF $min_quality_score IS NONE {0.7} ELSE {$min_quality_score};

    LET $topics = (
        SELECT 
            id,
            identity.code AS topic_code,
            domain->identity.code AS domain_code,
            domain.id AS domain_id,
            count((SELECT VALUE id FROM knowledge_content 
                   WHERE knowledge_content.topic = knowledge_topic.id 
                   AND knowledge_content.metadata.is_active = true
                   AND knowledge_content.metadata.quality_score >= $min_quality_score)) AS contents_count
        FROM knowledge_topic
        WHERE metadata.is_active = true
            AND (
                $domain_code IS NONE
                OR domain->identity.code = $domain_code
            )
        GROUP BY id
    );
    
    LET $gaps = (
        SELECT {
            gap_type: "missing_content",
            severity: IF contents_count = 0 THEN "critical" ELSE IF contents_count < 2 THEN "high" ELSE "medium" END,
            domain: domain_id,
            topic: id,
            content: NONE,
            description: "Topic '" + topic_code + "' a seulement " + contents_count + " contenu(s) de qualité (minimum recommandé: " + $min_content_count + ")",
            expected_content: "Ce topic nécessite au moins " + $min_content_count + " contenus de qualité >= " + $min_quality_score + " (SYNTAX, RULE, EXAMPLE_CORRECT recommandés)",
            detection_method: "automatic",
            detection_source: "detect_missing_content",
            detection_confidence: IF contents_count = 0 THEN 0.95 ELSE 0.7 END,
            detection_detected_at: time::now(),
            resolution_status: "pending",
            metadata_priority: IF contents_count = 0 THEN 5 ELSE IF contents_count < 2 THEN 3 ELSE 1 END,
            metadata_impact_score: IF contents_count = 0 THEN 0.9 ELSE IF contents_count < 2 THEN 0.7 ELSE 0.5 END,
            metadata_is_active: true,
            metadata_recurrence_count: 1
        }
        FROM $topics
        WHERE contents_count < $min_content_count
    );
    
    RETURN {
        success: true,
        gaps_detected: array::len($gaps),
        gaps: $gaps,
        filters: {
            domain_code: $domain_code,
            min_content_count: $min_content_count,
            min_quality_score: $min_quality_score
        },
        detected_at: time::now()
    };
};

