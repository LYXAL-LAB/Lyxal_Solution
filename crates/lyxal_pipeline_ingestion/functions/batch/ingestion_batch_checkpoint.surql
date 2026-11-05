-- ============================================================================
-- FONCTION : fn::ingestion_batch_checkpoint
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Point de reprise (checkpoint) du worker supervisé
-- APPEL    : interne (worker), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_checkpoint($params: object) {
    LET $id = fn::validation_record($params.id, "ingestion_batch");
    IF !$id.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "id", reason: $id.code }); };
    LET $counters = {
        cursor_offset: fn::validation_integer($params.cursor_offset, 0, NONE),
        total_lignes: fn::validation_integer($params.total_lignes, 0, NONE),
        lignes_verifiees: fn::validation_integer($params.lignes_verifiees, 0, NONE),
        lignes_a_confirmer: fn::validation_integer($params.lignes_a_confirmer, 0, NONE),
        lignes_rejetees: fn::validation_integer($params.lignes_rejetees, 0, NONE)
    };
    FOR $entry IN object::entries($counters) {
        IF !$entry[1].valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: $entry[0], reason: $entry[1].code }); };
    };

    LET $updated = (UPDATE ONLY $id.value SET
        cursor_offset = $counters.cursor_offset.value,
        total_lignes = $counters.total_lignes.value,
        lignes_verifiees = $counters.lignes_verifiees.value,
        lignes_a_confirmer = $counters.lignes_a_confirmer.value,
        lignes_rejetees = $counters.lignes_rejetees.value,
        last_checkpoint_at = time::now());
    IF $updated == NONE {
        IF !record::exists($id.value) {
            RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", NONE, { batch_id: <string> record::id($id.value) });
        };
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Met à jour l'avancement d'un lot et horodate le point de reprise sur incident";
