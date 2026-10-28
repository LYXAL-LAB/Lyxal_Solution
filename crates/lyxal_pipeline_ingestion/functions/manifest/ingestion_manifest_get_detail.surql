-- ============================================================================
-- FONCTION : fn::ingestion_manifest_get_detail
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consultation détaillée d'un manifeste avec intégrité de scellement
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_get_detail($params: object) {
    LET $manifest_ref = <string> $params.manifest_ref;
    LET $language = IF $params.language != NONE { <string> $params.language } ELSE { "fr" };

    LET $records = (SELECT 
        <string> id AS id,
        <string> batch AS batch,
        manifest_ref,
        manifest_version,
        seal_hash,
        is_sealed,
        statut,
        approved_by,
        IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at,
        approver_role,
        nb_articles_insert,
        nb_articles_update,
        items_committed,
        items_failed,
        execution_items,
        transitions,
        IF executed_at != NONE { <string> executed_at } ELSE { NONE } AS executed_at
    FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);

    IF array::len($records) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $language, { manifest_ref: $manifest_ref });
    };

    LET $manif = $records[0];
    LET $clean_b = string::replace($manif.batch, "ingestion_batch:", "");
    LET $b_rec = <record> string::concat('ingestion_batch:', $clean_b);
    LET $batch_info = (SELECT 
        <string> id AS id,
        fournisseur_id,
        nom_fichier,
        file_hash_blake3,
        statut,
        total_lignes,
        lignes_verifiees,
        lignes_a_confirmer,
        lignes_rejetees
    FROM $b_rec);

    RETURN fn::result_ok({
        manifest: $manif,
        batch: IF array::len($batch_info) > 0 { $batch_info[0] } ELSE { NONE },
        is_sealed: $manif.is_sealed,
        seal_hash: $manif.seal_hash,
        execution_count: IF $manif.execution_items != NONE { array::len($manif.execution_items) } ELSE { 0 },
        transition_count: IF $manif.transitions != NONE { array::len($manif.transitions) } ELSE { 0 }
    });
} COMMENT "Retourne le détail complet et l'état d'intégrité d'un manifeste de publication";
