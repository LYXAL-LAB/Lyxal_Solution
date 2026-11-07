-- ============================================================================
-- FONCTION : fn::ingestion_manifest_execution_item_update
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Journalisation de l'exécution d'un article d'un manifeste en cours de publication
-- APPEL    : externe (agent de synchronisation du catalogue), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_execution_item_update($params: object) {
    LET $fallback_language = IF type::is_string($params.language) { $params.language } ELSE { NONE };

    LET $who = fn::ingestion_session_identity({});
    IF $who.role NOT IN ["catalogue_sync_agent", "system"] {
        RETURN fn::error_result("INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED", $fallback_language, { role: $who.role, expected_role: "catalogue_sync_agent" });
    };

    LET $report = fn::validation_object_execute($params, {
        fields: {
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            item_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["INSERT", "UPDATE", "UNCHANGED", "DEPRECATE"], case_sensitive: false } }], required: true },
            success: { pipeline: [{ rule: "boolean" }], required: true },
            error: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 4000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $fallback_language, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { manifest_ref: { pipeline: [{ rule: "trim" }] }, action: { pipeline: [{ rule: "uppercase" }] } }, unknown_keys: "keep" }, 10);

    LET $manif = (SELECT id, statut FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    IF $manif == NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $p.language, { manifest_ref: $p.manifest_ref });
    };
    IF $manif.statut NOT IN ["APPROVED", "EXECUTING"] {
        RETURN fn::error_result("INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION", $p.language, { manifest_ref: $p.manifest_ref, current_status: $manif.statut, expected_status: ["APPROVED", "EXECUTING"] });
    };

    LET $updated = (UPDATE ONLY $manif.id SET
        execution_items = array::append(execution_items ?? [], {
            item_ref: $p.item_ref,
            action: $p.action,
            success: $p.success,
            error: $p.error,
            seal_hash: seal_hash,
            executed_at: time::now()
        }),
        items_committed += IF $p.success { 1 } ELSE { 0 },
        items_failed += IF $p.success { 0 } ELSE { 1 });
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Journalise l'exécution d'un article (référence, action, succès, erreur, sceau du contenu publié) d'un manifeste approuvé ou en cours d'exécution et met à jour ses compteurs ; réservé à catalogue_sync_agent (ou à la session système)"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
