-- ============================================================================
-- Fichier : knowledge/function/training/fn_knowledge_export_list_datasets.surql
-- Module : knowledge
-- Fonction : fn::knowledge_export_list_datasets()
-- Description : Liste les exports de datasets avec filtres optionnels
-- ============================================================================
-- Usage :
--   SELECT * FROM fn::knowledge_export_list_datasets("SURREAL_DB", true);
-- ============================================================================

DEFINE FUNCTION fn::knowledge_export_list_datasets(
    $domain_code: option<string>,
    $active_only: option<bool>,
    $limit: option<int>
) {
    -- Default values
    LET $active_only = IF $active_only IS NONE {true} ELSE {$active_only};
    LET $limit = IF $limit IS NONE {50} ELSE {$limit};

    -- Construire la requête de base
    LET $base_query = (
        SELECT {
            id: id,
            domain: {
                code: domain->identity.code,
                slug: domain->identity.slug
            },
            version: identity.version,
            name: identity.name,
            description: identity.description,
            export: {
                min_quality_score: export.min_quality_score,
                include_only_marked: export.include_only_marked,
                total_contents_found: export.total_contents_found,
                total_items_exported: export.total_items_exported,
                avg_quality_score: export.avg_quality_score,
                avg_training_weight: export.avg_training_weight
            },
            provenance: {
                created_by: provenance.created_by,
                export_type: provenance.export_type,
                trigger_reason: provenance.trigger_reason,
                source_version: provenance.source_version,
                file_path: provenance.file_path,
                file_size_bytes: provenance.file_size_bytes
            },
            metadata: {
                is_active: metadata.is_active,
                created_at: metadata.created_at,
                updated_at: metadata.updated_at,
                expires_at: metadata.expires_at,
                notes: metadata.notes
            }
        }
        FROM knowledge_dataset_export
        WHERE (
            $domain_code IS NONE
            OR domain->identity.code = $domain_code
        )
        AND (
            $active_only = false
            OR metadata.is_active = true
        )
        ORDER BY metadata.created_at DESC
        LIMIT $limit
        FETCH domain
    );

    -- Statistiques agrégées
    LET $stats = (
        SELECT {
            total_exports: count(),
            active_exports: count((SELECT VALUE id WHERE metadata.is_active = true)),
            total_items_exported: math::sum(export.total_items_exported),
            avg_quality_score: math::mean(export.avg_quality_score)
        }
        FROM knowledge_dataset_export
        WHERE (
            $domain_code IS NONE
            OR domain->identity.code = $domain_code
        )
        AND (
            $active_only = false
            OR metadata.is_active = true
        )
    )[0];

    RETURN {
        success: true,
        filters: {
            domain_code: $domain_code,
            active_only: $active_only,
            limit: $limit
        },
        stats: $stats,
        datasets: $base_query
    };
};

