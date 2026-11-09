-- ============================================================================
-- FONCTION : fn::ingestion_manifest_approve
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Approbation formelle du manifeste de publication par le Data Steward
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_approve($params: object) {
    LET $fallback_language = IF type::is_string($params.language) { $params.language } ELSE { NONE };

    -- Habilitation : permission de la session lyxal_auth (jamais dans les paramètres)
    IF !fn::auth_has_permission({ permission: "ingestion.manifest.approve" }) {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $fallback_language, { permission: "ingestion.manifest.approve" });
    };
    LET $operator = fn::ingestion_operator({});

    -- Entrées (la justification est contrôlée à part : code métier dédié)
    LET $report = fn::validation_object_execute($params, {
        fields: {
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            justification: { pipeline: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $fallback_language, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { manifest_ref: { pipeline: [{ rule: "trim" }] } }, unknown_keys: "keep" }, 10);
    LET $justif = fn::validation_required_string($p.justification, 10, 2000);
    IF !$justif.valid {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $p.language, { field: "justification", reason: $justif.code, min_required: 10 });
    };

    LET $manif = (SELECT id, statut, is_sealed, seal_hash FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    IF $manif == NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $p.language, { manifest_ref: $p.manifest_ref });
    };
    IF $manif.is_sealed != true {
        RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", $p.language, { manifest_ref: $p.manifest_ref });
    };

    -- La machine à états (SEALED ou FAILED vers APPROVED) est vérifiée par la garde evt_manifest_guard
    LET $now = time::now();
    LET $updated = (UPDATE ONLY $manif.id SET
        statut = "APPROVED",
        approved_by = $operator,
        approved_at = $now,
        transitions = array::append(transitions ?? [], {
            from_state: $manif.statut,
            to_state: "APPROVED",
            triggered_by: $operator,
            reason: $justif.value,
            transitioned_at: $now
        }));
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Approuve un manifeste scellé ; exige la permission ingestion.manifest.approve (AAL2) ; l'approbateur (opérateur de la session, ou « system ») est lu dans la session, jamais dans les paramètres ; la justification est journalisée"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
