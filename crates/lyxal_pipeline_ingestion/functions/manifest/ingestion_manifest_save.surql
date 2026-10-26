-- ============================================================================
-- FONCTION : fn::ingestion_manifest_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement et scellement d'un manifeste de publication
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_save($params: object) {
    LET $manifest_ref = <string> $params.manifest_ref;
    LET $batch_id = <string> $params.batch_id;
    LET $manifest_version = IF $params.manifest_version != NONE { <int> $params.manifest_version } ELSE { 1 };
    LET $seal_hash = <string> $params.seal_hash;
    LET $is_sealed = IF $params.is_sealed != NONE { <bool> $params.is_sealed } ELSE { true };
    LET $statut = IF $params.statut != NONE { string::uppercase(<string> $params.statut) } ELSE { "DRAFT" };
    LET $approved_by = IF $params.approved_by != NONE { <string> $params.approved_by } ELSE { NONE };
    LET $approved_at = IF $params.approved_at != NONE { <datetime> $params.approved_at } ELSE { NONE };
    LET $approver_role = IF $params.approver_role != NONE { <string> $params.approver_role } ELSE { NONE };
    LET $nb_articles_insert = IF $params.nb_articles_insert != NONE { <int> $params.nb_articles_insert } ELSE { 0 };
    LET $nb_articles_update = IF $params.nb_articles_update != NONE { <int> $params.nb_articles_update } ELSE { 0 };
    LET $items_committed = IF $params.items_committed != NONE { <int> $params.items_committed } ELSE { 0 };
    LET $items_failed = IF $params.items_failed != NONE { <int> $params.items_failed } ELSE { 0 };
    LET $execution_items = IF $params.execution_items != NONE { $params.execution_items } ELSE { [] };
    LET $transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] };
    LET $executed_at = IF $params.executed_at != NONE { <datetime> $params.executed_at } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $is_sealed == true AND string::len($seal_hash) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", $language, { manifest_ref: $manifest_ref });
    };

    LET $batch_rec = <record> string::concat('ingestion_batch:', $batch_id);

    LET $existing = (SELECT id FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
    IF array::len($existing) > 0 {
        LET $target_id = $existing[0].id;
        UPDATE $target_id SET
            manifest_version = $manifest_version,
            seal_hash = $seal_hash,
            is_sealed = $is_sealed,
            statut = $statut,
            approved_by = $approved_by,
            approved_at = $approved_at,
            approver_role = $approver_role,
            nb_articles_insert = $nb_articles_insert,
            nb_articles_update = $nb_articles_update,
            items_committed = $items_committed,
            items_failed = $items_failed,
            execution_items = $execution_items,
            transitions = $transitions,
            executed_at = $executed_at;
    } ELSE {
        CREATE ingestion_publication_manifest CONTENT {
            batch: $batch_rec,
            manifest_ref: $manifest_ref,
            manifest_version: $manifest_version,
            seal_hash: $seal_hash,
            is_sealed: $is_sealed,
            statut: $statut,
            approved_by: $approved_by,
            approved_at: $approved_at,
            approver_role: $approver_role,
            nb_articles_insert: $nb_articles_insert,
            nb_articles_update: $nb_articles_update,
            items_committed: $items_committed,
            items_failed: $items_failed,
            execution_items: $execution_items,
            transitions: $transitions,
            executed_at: $executed_at
        };
    };

    RETURN fn::result_ok($manifest_ref);
} COMMENT "Enregistre ou met à jour un manifeste de publication avec empreinte cryptographique BLAKE3";
