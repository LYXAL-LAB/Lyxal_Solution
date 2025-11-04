-- ============================================================================
-- Fichier : knowledge/function/training/fn_knowledge_export_create_dataset.surql
-- Module : knowledge
-- Fonction : fn::knowledge_export_create_dataset()
-- Description : Crée un export de dataset avec versioning automatique et tracking
-- ============================================================================
-- Usage :
--   SELECT * FROM fn::knowledge_export_create_dataset("SURREAL_DB", 0.7, "manual", "user_123");
-- ============================================================================

DEFINE FUNCTION fn::knowledge_export_create_dataset(
    $domain_code: string,
    $min_quality_score: option<number>,
    $export_type: option<string>,
    $created_by: option<string>,
    $description: option<string>,
    $auto_version: option<bool>
) {
    -- Default values
    LET $min_quality_score = IF $min_quality_score IS NONE {0.7} ELSE {$min_quality_score};
    LET $export_type = IF $export_type IS NONE {"manual"} ELSE {$export_type};
    LET $auto_version = IF $auto_version IS NONE {true} ELSE {$auto_version};

    -- Vérifier que le domaine existe
    LET $domain = (SELECT * FROM knowledge_domain WHERE identity.code = $domain_code AND metadata.is_active = true LIMIT 1)[0];
    
    IF $domain = NONE {
        RETURN {
            success: false,
            error: "Domain not found",
            domain_code: $domain_code
        };
    };

    -- Générer la version automatiquement si demandé
    LET $version_result = IF $auto_version THEN (
        SELECT * FROM fn::knowledge_export_auto_version($domain_code)
    )[0] ELSE { success: false };
    
    LET $version = IF $auto_version AND $version_result.success THEN 
        $version_result.next_version 
    ELSE NONE;

    -- Si auto_version est false et pas de version fournie, erreur
    IF $version = NONE {
        RETURN {
            success: false,
            error: "Version is required when auto_version is false. Provide a version or set auto_version to true."
        };
    };

    -- Générer le nom du dataset
    LET $dataset_name = string::concat($domain_code, string::concat("_", string::replace($version, "v", "v")));

    -- Vérifier que le nom n'existe pas déjà
    LET $existing = (SELECT VALUE count() FROM knowledge_dataset_export WHERE identity.name = $dataset_name)[0];
    IF $existing > 0 {
        RETURN {
            success: false,
            error: "Dataset name already exists",
            dataset_name: $dataset_name
        };
    };

    -- Exécuter l'export en utilisant la fonction existante
    LET $export_result = (SELECT * FROM fn::knowledge_export_domain_for_training($domain_code, $min_quality_score, $version, false))[0];

    IF $export_result.success != true {
        RETURN {
            success: false,
            error: "Export failed",
            details: $export_result
        };
    };

    -- Créer l'enregistrement de tracking
    LET $export_record = CREATE knowledge_dataset_export SET
        domain = $domain.id,
        identity.version = $version,
        identity.name = $dataset_name,
        identity.description = $description,
        export.min_quality_score = $min_quality_score,
        export.include_only_marked = false,
        export.total_contents_found = $export_result.stats.total_contents_found,
        export.total_items_exported = $export_result.stats.total_items_exported,
        export.avg_quality_score = $export_result.stats.avg_quality_score,
        export.avg_training_weight = $export_result.stats.avg_training_weight,
        provenance.created_by = $created_by,
        provenance.export_type = $export_type,
        provenance.source_version = NONE,
        metadata.is_active = true,
        metadata.created_at = time::now(),
        metadata.updated_at = time::now();

    -- Mettre à jour les métadonnées d'entraînement des contenus exportés
    UPDATE knowledge_content SET
        metadata.training.training_versions = array::append(metadata.training.training_versions, $version),
        metadata.training.last_training_date = time::now()
    WHERE topic.domain = $domain.id
        AND metadata.is_active = true
        AND metadata.quality_score >= $min_quality_score;

    RETURN {
        success: true,
        export_record: $export_record,
        export_stats: $export_result.stats,
        version: $version,
        dataset_name: $dataset_name
    };
};

