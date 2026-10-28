-- ============================================================================
-- FONCTION : fn::ingestion_batch_transition
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Transition d'état contrôlée d'un lot d'ingestion avec audit trail
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_transition($params: object) {
    LET $id = <string> $params.id;
    LET $nouveau_statut = <string> $params.nouveau_statut;
    LET $transition = $params.transition;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $record_id = <record> string::concat('ingestion_batch:', $id);

    LET $existing = (SELECT * FROM ONLY $record_id);
    IF $existing == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $language, { batch_id: $id });
    };

    -- Contrôle d'état terminal
    IF $existing.statut IN ["Completed", "Failed", "Aborted"] AND $nouveau_statut != $existing.statut {
        RETURN fn::error_result("INGESTION_BATCH_TERMINAL_STATE", $language, { 
            batch_id: $id, 
            current_status: $existing.statut, 
            requested_status: $nouveau_statut 
        });
    };

    LET $is_completed = $nouveau_statut IN ["Completed", "Failed", "Aborted"];

    UPDATE $record_id SET
        statut = $nouveau_statut,
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$transition]),
        completed_at = IF $is_completed { time::now() } ELSE { completed_at },
        last_checkpoint_at = time::now();

    RETURN fn::result_ok(true);
} COMMENT "Applique une transition d'état sur un lot avec contrôle des états terminaux et consignation immuable";
