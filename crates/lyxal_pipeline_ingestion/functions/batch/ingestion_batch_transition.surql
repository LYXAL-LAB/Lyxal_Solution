-- ============================================================================
-- FONCTION : fn::ingestion_batch_transition
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Transition d'état d'un lot, journalisée au nom de l'identité de session
-- APPEL    : interne (worker, à chaque changement d'état), entrées contrôlées par le moteur de lyxal_core
-- ERREUR   : error_code (code de l'échec) obligatoire pour FAILED, refusé pour les autres états ;
--            il est journalisé dans la transition et repris par l'événement ingestion.batch.failed
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_transition($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            nouveau_statut: { pipeline: [{ rule: "enum", options: { allowed: ["RECEIVED", "PARSING", "VALIDATING", "STAGED", "PUBLISHED", "FAILED"], case_sensitive: false } }], required: true },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2000 } }], required: true },
            claim: { pipeline: [{ rule: "is_object" }], required: true },
            error_code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]*$" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = { value: $p.id };
    LET $statut = { value: $p.nouveau_statut };
    LET $reason = { value: $p.reason };

    -- Cloisonnement : seule l'exécution qui détient la réservation du lot écrit
    LET $held = fn::ingestion_batch_claim_verify({ batch_id: $id.value, claim: $report.value.claim, language: $p.language });
    IF !$held.ok { RETURN $held; };

    LET $existing = (SELECT statut FROM ONLY $id.value);
    IF $existing == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $p.language, { batch_id: <string> record::id($id.value) });
    };
    LET $target = string::uppercase($statut.value);
    -- Le code d'erreur accompagne le passage à FAILED, et lui seul (événement ingestion.batch.failed)
    IF $target = "FAILED" AND $p.error_code == NONE {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $p.language, { fields: { error_code: ["CORE_VALIDATION_REQUIRED"] } });
    };
    IF $target != "FAILED" AND $p.error_code != NONE {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $p.language, { fields: { error_code: ["CORE_VALIDATION_NOT_ALLOWED"] } });
    };
    IF $existing.statut == "PUBLISHED" {
        RETURN fn::error_result("INGESTION_BATCH_TERMINAL_STATE", $p.language, { batch_id: <string> record::id($id.value), current_status: $existing.statut, requested_status: $target });
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
            error_code: $p.error_code,
            transitioned_at: $now
        }),
        completed_at = IF $target IN ["STAGED", "PUBLISHED", "FAILED"] { $now } ELSE { completed_at },
        last_checkpoint_at = $now);
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Applique une transition d'état sur un lot ; la transition (état d'origine, auteur de la session, motif, code d'erreur pour FAILED, horodatage) est construite et journalisée par la fonction ; écriture réservée à l'exécution qui détient le lot (claim { owner, generation }, sinon INGESTION_BATCH_CLAIM_LOST)";
