-- ============================================================================
-- Fichier : knowledge/function/training/fn_knowledge_export_domain_for_training.surql
-- Module : knowledge
-- Fonction : fn::knowledge_export_domain_for_training()
-- Description : Exporte les contenus d'un domaine pour entraînement IA au format structuré (JSONL-ready)
-- ============================================================================
-- Usage :
--   SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.0");
-- ============================================================================

DEFINE FUNCTION fn::knowledge_export_domain_for_training(
    $domain_code: string,
    $min_quality_score: option<number>,
    $dataset_version: option<string>,
    $include_only_marked: option<bool>
) {
    -- Default values
    LET $min_quality_score = IF $min_quality_score IS NONE {0.7} ELSE {$min_quality_score};
    LET $include_only_marked = IF $include_only_marked IS NONE {false} ELSE {$include_only_marked};

    -- Vérifier que le domaine existe
    LET $domain = (SELECT * FROM knowledge_domain WHERE identity.code = $domain_code AND metadata.is_active = true LIMIT 1)[0];
    
    IF $domain = NONE {
        RETURN {
            success: false,
            error: "Domain not found",
            domain_code: $domain_code
        };
    };

    -- Compter les contenus éligibles
    LET $total_contents = (
        SELECT VALUE count()
        FROM knowledge_content
        WHERE topic.domain = $domain.id
            AND metadata.is_active = true
            AND metadata.quality_score >= $min_quality_score
            AND (
                $include_only_marked = false
                OR metadata.training.included_in_training = true
            )
    )[0];

    -- Transformer en format JSONL-ready avec pondération
    LET $export_data = (
        SELECT {
            id: id,
            slug: identity.slug,
            domain: {
                code: topic.domain->identity.code,
                slug: topic.domain->identity.slug
            },
            topic: {
                code: topic->identity.code,
                slug: topic->identity.slug,
                label_key: topic->identity.label_key
            },
            content_type: {
                code: identity.content_type->identity.code,
                label_key: identity.content_type->identity.label_key
            },
            title_key: identity.title_key,
            description_key: identity.description_key,
            content: {
                text_key: content.text_key,
                code: content.code,
                prompt: content.prompt,
                json: content.json,
                context_key: content.context_key,
                examples: content.examples,
                media: content.media
            },
            tags: tags,
            metadata: {
                priority: metadata.priority,
                version_label: metadata.version_label,
                quality_score: metadata.quality_score,
                training_weight: IF metadata.training.training_weight IS NONE {1.0} ELSE {metadata.training.training_weight},
                training_versions: metadata.training.training_versions,
                analytics: {
                    view_count: metadata.analytics.view_count,
                    ai_usage_count: metadata.analytics.ai_usage_count
                }
            },
            dataset_version: $dataset_version,
            exported_at: time::now()
        }
        FROM knowledge_content
        WHERE topic.domain = $domain.id
            AND metadata.is_active = true
            AND metadata.quality_score >= $min_quality_score
            AND (
                $include_only_marked = false
                OR metadata.training.included_in_training = true
            )
        ORDER BY metadata.training.training_weight DESC, metadata.quality_score DESC
        FETCH topic, identity.content_type
    );

    -- Statistiques de l'export
    LET $stats = {
        domain_code: $domain_code,
        dataset_version: $dataset_version,
        min_quality_score: $min_quality_score,
        include_only_marked: $include_only_marked,
        total_contents_found: $total_contents,
        total_items_exported: array::len($export_data),
        exported_at: time::now(),
        avg_quality_score: (
            SELECT VALUE math::mean(metadata.quality_score)
            FROM knowledge_content
            WHERE topic.domain = $domain.id
                AND metadata.is_active = true
                AND metadata.quality_score >= $min_quality_score
                AND (
                    $include_only_marked = false
                    OR metadata.training.included_in_training = true
                )
        )[0],
        avg_training_weight: (
            SELECT VALUE math::mean(IF metadata.training.training_weight IS NONE {1.0} ELSE {metadata.training.training_weight})
            FROM knowledge_content
            WHERE topic.domain = $domain.id
                AND metadata.is_active = true
                AND metadata.quality_score >= $min_quality_score
                AND (
                    $include_only_marked = false
                    OR metadata.training.included_in_training = true
                )
        )[0]
    };

    RETURN {
        success: true,
        stats: $stats,
        data: $export_data
    };
};

