-- ============================================================================
-- FONCTION : fn::ingestion_batch_transition
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Transition d'état d'un lot, journalisée au nom de l'identité de session
-- APPEL    : interne (worker), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_transition($params: object) {
    LET $id = fn::validation_record($params.id, "ingestion_batch");
    IF !$id.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "id", reason: $id.code }); };
    LET $statut = fn::validation_enum($params.nouveau_statut, ["RECEIVED", "PARSING", "VALIDATING", "STAGED", "PUBLISHED", "FAILED"], false);
    IF !$statut.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "nouveau_statut", reason: $statut.code }); };
    LET $reason = fn::validation_required_string($params.reason, 1, 2000);
    IF !$reason.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "reason", reason: $reason.code }); };

    LET $existing = (SELECT statut FROM ONLY $id.value);
    IF $existing == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", NONE, { batch_id: <string> record::id($id.value) });
    };
    LET $target = string::uppercase($statut.value);
    IF $existing.statut == "PUBLISHED" {
        RETURN fn::error_result("INGESTION_BATCH_TERMINAL_STATE", NONE, { batch_id: <string> record::id($id.value), current_status: $existing.statut, requested_status: $target });
    };

    -- La machine à états est vérifiée par la garde evt_batch_guard (INGESTION_BATCH_ILLEGAL_STATE_TRANSITION)
    LET $now = time::now();
    LET $updated = (UPDATE ONLY $id.value SET
        statut = $target,
        transitions = array::append(transitions ?? [], {
            from_state: $existing.statut,
            to_state: $target,
            triggered_by: fn::ingestion_session_identity({}).operator,
            reason: $reason.value,
            transitioned_at: $now
        }),
        completed_at = IF $target IN ["STAGED", "PUBLISHED", "FAILED"] { $now } ELSE { completed_at },
        last_checkpoint_at = $now);
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Applique une transition d'état sur un lot ; la transition (état d'origine, auteur de la session, motif, horodatage) est construite et journalisée par la fonction";
