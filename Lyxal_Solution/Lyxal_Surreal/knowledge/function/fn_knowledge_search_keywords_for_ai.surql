-- ============================================================================
-- Fichier : knowledge/function/fn_knowledge_search_keywords_for_ai.surql
-- Module : knowledge
-- Fonction : fn::knowledge_search_keywords_for_ai()
-- Description : Recherche par mots-clés avec scoring BM25, optimisée pour IA
-- ============================================================================
-- Usage avec valeurs par défaut :
--   SELECT * FROM fn::knowledge_search_keywords_for_ai(
--     ["database", "field", "validation"],
--     "SURREAL_DB"
--   );
-- 
-- Usage avec paramètres personnalisés :
--   SELECT * FROM fn::knowledge_search_keywords_for_ai(
--     ["database", "field", "validation"],
--     "SURREAL_DB",
--     20  -- limit personnalisé
--   );
-- ============================================================================

DEFINE FUNCTION fn::knowledge_search_keywords_for_ai(
    $keywords: array<string>,
    $domain_code: option<string>,
    $limit: option<number>
) {
    -- Default values
    LET $limit = IF $limit IS NONE {10} ELSE {$limit};

    LET $results_raw = (
        SELECT *, search::score() AS score
        FROM knowledge_topic_keyword
        WHERE out.identity.value @1@ array::join($keywords, " ")
            AND (
                $domain_code IS NONE
                OR in->domain->identity.code = $domain_code
            )
            AND in->metadata.is_active = true
        GROUP BY in
        ORDER BY score DESC
        LIMIT $limit
    );
    LET $results = (
        SELECT {
            topic: {
                id: in.id,
                code: in->identity.code,
                slug: in->identity.slug,
                label_key: in->identity.label_key,
                description_key: in->identity.description_key,
                domain: {
                    id: in->domain.id,
                    code: in->domain->identity.code,
                    slug: in->domain->identity.slug
                }
            },
            keyword_match: out.identity.value,
            score: score,
            contents_count: count((
                SELECT VALUE id
                FROM knowledge_content
                WHERE knowledge_content.topic = in.id
                    AND knowledge_content.metadata.is_active = true
                    AND knowledge_content.metadata.quality_score >= 0.7
            )),
            best_content: (
                SELECT {
                    id: id,
                    slug: identity.slug,
                    type: identity.content_type->identity.code,
                    quality_score: metadata.quality_score,
                    priority: metadata.priority
                }
                FROM (
                    SELECT id,
                        metadata.quality_score AS sort_quality,
                        metadata.priority AS sort_priority
                    FROM knowledge_content
                    WHERE knowledge_content.topic = in.id
                        AND knowledge_content.metadata.is_active = true
                        AND knowledge_content.metadata.quality_score >= 0.7
                    ORDER BY 
                        sort_quality DESC,
                        sort_priority DESC
                    LIMIT 1
                )
                FETCH identity.content_type
            )[0]
        }
        FROM $results_raw
    );
    
    -- Tracking automatique : incrémenter les compteurs pour le meilleur contenu de chaque résultat (utilisation IA)
    FOR $result_item IN $results {
        IF $result_item.best_content != NONE AND $result_item.best_content.id != NONE {
            LET $track_result = (SELECT * FROM fn::knowledge_track_content_access($result_item.best_content.id, true));
        };
    };
    
    RETURN {
        success: true,
        results: $results,
        metadata: {
            keywords_searched: $keywords,
            domain_filter: $domain_code,
            total_results: array::len($results),
            limit: $limit,
            query_time: time::now()
        }
    };
};

