-- ============================================================================
-- FONCTION : fn::ingestion_manifest_record_exec
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Compte rendu final de l'exécution d'un manifeste approuvé
-- APPEL    : externe (agent de synchronisation du catalogue), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_record_exec($params: object) {
    LET $fallback_language = IF type::is_string($params.language) { $params.language } ELSE { NONE };

    -- Habilitation : seul l'agent de synchronisation (ou la session système) exécute la publication
    LET $who = fn::ingestion_session_identity({});
    IF $who.role NOT IN ["catalogue_sync_agent", "system"] {
        RETURN fn::error_result("INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED", $fallback_language, { role: $who.role, expected_role: "catalogue_sync_agent" });
    };

    LET $report = fn::validation_object_execute($params, {
        fields: {
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            statut: { pipeline: [{ rule: "enum", options: { allowed: ["COMMITTED", "FAILED"], case_sensitive: false } }], required: true },
            items_committed: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            items_failed: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $fallback_language, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { manifest_ref: { pipeline: [{ rule: "trim" }] }, statut: { pipeline: [{ rule: "uppercase" }] } }, unknown_keys: "keep" }, 10);

    LET $manif = (SELECT id, statut FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    IF $manif == NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $p.language, { manifest_ref: $p.manifest_ref });
    };
    IF $manif.statut NOT IN ["APPROVED", "EXECUTING"] {
        RETURN fn::error_result("INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION", $p.language, { manifest_ref: $p.manifest_ref, current_status: $manif.statut, requested_status: $p.statut });
    };

    -- Un manifeste approuvé passe par EXECUTING avant son état final (machine à états vérifiée par evt_manifest_guard)
    LET $now = time::now();
    LET $from = IF $manif.statut = "APPROVED" {
        LET $executing = (UPDATE ONLY $manif.id SET
            statut = "EXECUTING",
            transitions = array::append(transitions ?? [], { from_state: "APPROVED", to_state: "EXECUTING", triggered_by: $who.operator, reason: "Début de la publication", transitioned_at: $now }));
        IF $executing == NONE { NONE } ELSE { "EXECUTING" }
    } ELSE { $manif.statut };
    IF $from == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };

    LET $updated = (UPDATE ONLY $manif.id SET
        statut = $p.statut,
        items_committed = $p.items_committed,
        items_failed = $p.items_failed,
        executed_at = $now,
        transitions = array::append(transitions ?? [], { from_state: $from, to_state: $p.statut, triggered_by: $who.operator, reason: "Compte rendu d'exécution de la publication", transitioned_at: $now }));
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Consigne l'issue (COMMITTED ou FAILED) et les compteurs de l'exécution d'un manifeste approuvé ; réservé à catalogue_sync_agent (ou à la session système) lu dans la session"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
