-- ============================================================================
-- Fichier : knowledge/function/fn_knowledge_get_domain_overview_for_ai.surql
-- Module : knowledge
-- Fonction : fn::knowledge_get_domain_overview_for_ai()
-- Description : Vue d'ensemble d'un domaine avec ses topics et statistiques
-- ============================================================================
-- Usage :
--   SELECT * FROM fn::knowledge_get_domain_overview_for_ai("SURREAL_DB");
-- ============================================================================

DEFINE FUNCTION fn::knowledge_get_domain_overview_for_ai(
    $domain_code: string
) {
    LET $domain = (SELECT * FROM knowledge_domain WHERE identity.code = $domain_code AND metadata.is_active = true LIMIT 1)[0];
    LET $topics_sorted = (
        SELECT *, count((SELECT VALUE id FROM knowledge_content WHERE knowledge_content.topic = knowledge_topic.id AND knowledge_content.metadata.is_active = true)) AS contents_count_sort
        FROM knowledge_topic
        WHERE knowledge_topic.domain = $domain.id
            AND knowledge_topic.metadata.is_active = true
        ORDER BY contents_count_sort DESC
    );
    RETURN {
        success: true,
        domain: {
            id: $domain.id,
            code: $domain.identity.code,
            slug: $domain.identity.slug,
            label_key: $domain.identity.label_key,
            description_key: $domain.identity.description_key,
            ai_context_key: $domain.identity.ai_context_key,
            icon: $domain.ui.icon,
            tags: $domain.tags,
            keywords: array::distinct(array::flatten((
                SELECT VALUE out.identity.value
                FROM ->knowledge_domain_keyword->out
                WHERE in = $domain.id
            )))
        },
        topics: (
            SELECT {
                id: id,
                code: identity.code,
                slug: identity.slug,
                label_key: identity.label_key,
                description_key: identity.description_key,
                category: {
                    code: category->identity.code,
                    slug: category->identity.slug
                },
                contents_count: count((
                    SELECT VALUE id
                    FROM knowledge_content
                    WHERE knowledge_content.topic = id
                        AND knowledge_content.metadata.is_active = true
                )),
                high_quality_contents_count: count((
                    SELECT VALUE id
                    FROM knowledge_content
                    WHERE knowledge_content.topic = id
                        AND knowledge_content.metadata.is_active = true
                        AND knowledge_content.metadata.quality_score >= 0.7
                )),
                keywords: array::distinct(array::flatten((
                    SELECT VALUE out.identity.value
                    FROM ->knowledge_topic_keyword->out
                    WHERE in = id
                ))),
                best_content_quality: (
                    SELECT VALUE math::max(metadata.quality_score)
                    FROM knowledge_content
                    WHERE knowledge_content.topic = id
                        AND knowledge_content.metadata.is_active = true
                )[0]
            }
            FROM $topics_sorted
        ),
        statistics: {
            total_topics: count($topics_sorted),
            total_contents: math::sum((
                SELECT VALUE count()
                FROM knowledge_content
                WHERE knowledge_content.topic.id IN (SELECT VALUE id FROM $topics_sorted)
                AND knowledge_content.metadata.is_active = true
            ))[0],
            high_quality_contents: math::sum((
                SELECT VALUE count()
                FROM knowledge_content
                WHERE knowledge_content.topic.id IN (SELECT VALUE id FROM $topics_sorted)
                AND knowledge_content.metadata.is_active = true
                AND knowledge_content.metadata.quality_score >= 0.7
            ))[0],
            avg_quality_score: math::mean((
                SELECT VALUE metadata.quality_score
                FROM knowledge_content
                WHERE knowledge_content.topic.id IN (SELECT VALUE id FROM $topics_sorted)
                AND knowledge_content.metadata.is_active = true
            ))
        },
        metadata: {
            domain_code: $domain_code,
            query_time: time::now()
        }
    };
};

