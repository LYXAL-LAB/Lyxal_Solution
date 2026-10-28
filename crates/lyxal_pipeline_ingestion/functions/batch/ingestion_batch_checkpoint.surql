-- ============================================================================
-- FONCTION : fn::ingestion_batch_checkpoint
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un point de reprise (checkpoint) pour le worker supervisé
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_checkpoint($params: object) {
    LET $id = <string> $params.id;
    LET $cursor_offset = <int> $params.cursor_offset;
    LET $total_lignes = IF $params.total_lignes != NONE { <int> $params.total_lignes } ELSE { NONE };
    LET $lignes_verifiees = <int> $params.lignes_verifiees;
    LET $lignes_a_confirmer = <int> $params.lignes_a_confirmer;
    LET $lignes_rejetees = <int> $params.lignes_rejetees;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $record_id = <record> string::concat('ingestion_batch:', $id);

    LET $existing = (SELECT * FROM ONLY $record_id);
    IF $existing == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $language, { batch_id: $id });
    };

    UPDATE $record_id SET
        cursor_offset = $cursor_offset,
        total_lignes = IF $total_lignes != NONE { $total_lignes } ELSE { total_lignes },
        lignes_verifiees = $lignes_verifiees,
        lignes_a_confirmer = $lignes_a_confirmer,
        lignes_rejetees = $lignes_rejetees,
        last_checkpoint_at = time::now();

    RETURN fn::result_ok(true);
} COMMENT "Met à jour l'avancement d'un lot et horodate le checkpoint pour la reprise sur incident";
