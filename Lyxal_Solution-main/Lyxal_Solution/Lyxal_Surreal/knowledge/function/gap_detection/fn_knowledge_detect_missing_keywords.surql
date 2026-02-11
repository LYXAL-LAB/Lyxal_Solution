-- ============================================================================
-- Fichier : knowledge/function/gap_detection/fn_knowledge_detect_missing_keywords.surql
-- Module : knowledge
-- Fonction : fn::knowledge_gap_detect_missing_keywords()
-- Description : Détecte les topics/domaines avec peu ou pas de keywords pour la recherche
-- ============================================================================

DEFINE FUNCTION fn::knowledge_gap_detect_missing_keywords(
    $domain_code: option<string>,
    $min_keyword_count: option<number>
) {
    -- Default values
    LET $min_keyword_count = IF $min_keyword_count IS NONE {3} ELSE {$min_keyword_count};

    -- Détection pour les topics
    LET $topics_with_keywords = (
        SELECT 
            id,
            identity.code AS topic_code,
            domain->identity.code AS domain_code,
            domain.id AS domain_id,
            count((SELECT VALUE id FROM knowledge_topic_keyword 
                   WHERE knowledge_topic_keyword.in = knowledge_topic.id)) AS keyword_count
        FROM knowledge_topic
        WHERE metadata.is_active = true
            AND (
                $domain_code IS NONE
                OR domain->identity.code = $domain_code
            )
        GROUP BY id
    );
    
    LET $gaps_topics = (
        SELECT {
            gap_type: "missing_keywords",
            severity: IF keyword_count = 0 THEN "high" ELSE "medium" END,
            domain: domain_id,
            topic: id,
            content: NONE,
            description: "Topic '" + topic_code + "' a seulement " + keyword_count + " mot(s)-clé(s) (minimum recommandé: " + $min_keyword_count + ")",
            expected_content: "Ce topic nécessite au moins " + $min_keyword_count + " mots-clés pour améliorer la découvrabilité via recherche full-text",
            suggested_keywords: [],
            detection_method: "automatic",
            detection_source: "detect_missing_keywords",
            detection_confidence: 0.8,
            detection_detected_at: time::now(),
            resolution_status: "pending",
            metadata_priority: IF keyword_count = 0 THEN 3 ELSE 2 END,
            metadata_impact_score: IF keyword_count = 0 THEN 0.7 ELSE 0.5 END,
            metadata_is_active: true,
            metadata_recurrence_count: 1
        }
        FROM $topics_with_keywords
        WHERE keyword_count < $min_keyword_count
    );
    
    -- Détection pour les domaines
    LET $domains_with_keywords = (
        SELECT 
            id,
            identity.code AS domain_code,
            count((SELECT VALUE id FROM knowledge_domain_keyword 
                   WHERE knowledge_domain_keyword.in = knowledge_domain.id)) AS keyword_count
        FROM knowledge_domain
        WHERE metadata.is_active = true
            AND (
                $domain_code IS NONE
                OR identity.code = $domain_code
            )
        GROUP BY id
    );
    
    LET $gaps_domains = (
        SELECT {
            gap_type: "missing_keywords",
            severity: IF keyword_count = 0 THEN "high" ELSE "medium" END,
            domain: id,
            topic: NONE,
            content: NONE,
            description: "Domaine '" + domain_code + "' a seulement " + keyword_count + " mot(s)-clé(s) (minimum recommandé: " + $min_keyword_count + ")",
            expected_content: "Ce domaine nécessite au moins " + $min_keyword_count + " mots-clés pour améliorer la découvrabilité",
            suggested_keywords: [],
            detection_method: "automatic",
            detection_source: "detect_missing_keywords",
            detection_confidence: 0.8,
            detection_detected_at: time::now(),
            resolution_status: "pending",
            metadata_priority: IF keyword_count = 0 THEN 3 ELSE 2 END,
            metadata_impact_score: IF keyword_count = 0 THEN 0.7 ELSE 0.5 END,
            metadata_is_active: true,
            metadata_recurrence_count: 1
        }
        FROM $domains_with_keywords
        WHERE keyword_count < $min_keyword_count
    );
    
    RETURN {
        success: true,
        gaps_detected: array::len($gaps_topics) + array::len($gaps_domains),
        gaps_topics: $gaps_topics,
        gaps_domains: $gaps_domains,
        filters: {
            domain_code: $domain_code,
            min_keyword_count: $min_keyword_count
        },
        detected_at: time::now()
    };
};

