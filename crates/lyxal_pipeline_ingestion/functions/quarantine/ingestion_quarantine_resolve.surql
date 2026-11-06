-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_resolve
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution auditable d'une anomalie en quarantaine par le Data Steward
-- APPEL    : externe (console Data Steward), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_resolve($params: object) {
    LET $fallback_language = IF type::is_string($params.language) { $params.language } ELSE { NONE };

    -- 1. Habilitation : identité lue dans la session (jamais dans les paramètres)
    LET $who = fn::ingestion_session_identity({});
    IF $who.role NOT IN ["steward_admin", "system"] {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $fallback_language, { role: $who.role, expected_role: "steward_admin" });
    };

    -- 2. Entrées (le commentaire est contrôlé à part : code métier dédié)
    LET $report = fn::validation_object_execute($params, {
        fields: {
            quarantine_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_quarantine_record" } }], required: true },
            comment: { pipeline: [] },
            staged_item_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_staged_item" } }] },
            corrections: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $fallback_language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $justif = fn::validation_required_string($p.comment, 10, 2000);
    IF !$justif.valid {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $p.language, { field: "comment", reason: $justif.code, min_required: 10 });
    };

    -- 3. Corrections : code-barres contrôlé par lyxal_core, unité résolue par le référentiel
    LET $corrections = $p.corrections ?? {};
    LET $gtin = IF $corrections.corrected_gtin != NONE { fn::validation_gtin($corrections.corrected_gtin) } ELSE { { valid: true, value: NONE } };
    IF !$gtin.valid {
        RETURN fn::error_result("INGESTION_GTIN_INVALID", $p.language, { field: "corrections.corrected_gtin", reason: $gtin.code });
    };
    LET $unit_code = IF $corrections.corrected_unit != NONE {
        LET $units = fn::ingestion_resolve_units({ raw_units: [$corrections.corrected_unit] });
        IF $units.ok { object::values($units.data)[0] } ELSE { NONE }
    } ELSE { NONE };
    IF $corrections.corrected_unit != NONE AND $unit_code == NONE {
        RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", $p.language, { field: "corrections.corrected_unit", raw_unit: $corrections.corrected_unit });
    };

    -- 4. Anomalie
    IF (SELECT VALUE id FROM ONLY $p.quarantine_id) == NONE {
        RETURN fn::error_result("INGESTION_RECORD_NOT_FOUND", $p.language, { quarantine_id: <string> record::id($p.quarantine_id) });
    };
    LET $staged = IF $p.staged_item_id != NONE { (SELECT qualification, code_barre_gtin, unite_reference, transitions FROM ONLY $p.staged_item_id) } ELSE { NONE };
    IF $p.staged_item_id != NONE AND $staged == NONE {
        RETURN fn::error_result("INGESTION_ITEM_NOT_FOUND", $p.language, { item_id: <string> record::id($p.staged_item_id) });
    };

    LET $now = time::now();
    LET $resolved = (UPDATE ONLY $p.quarantine_id SET
        is_resolved = true,
        resolved_by = $who.operator,
        resolved_at = $now,
        resolution_comment = $justif.value);
    IF $resolved == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_quarantine_record" });
    };

    -- 5. Article lié : toute correction le repasse en TO_CONFIRM (jamais VERIFIED directement)
    IF $staged != NONE {
        LET $reason = string::concat("Correction suite anomalie quarantaine : ", $justif.value);
        LET $updated = (UPDATE ONLY $p.staged_item_id SET
            qualification = "TO_CONFIRM",
            qualification_reason = $reason,
            code_barre_gtin = $gtin.value ?? code_barre_gtin,
            unite_reference = $unit_code ?? unite_reference,
            conditionnement.unite_vente = $unit_code ?? conditionnement.unite_vente,
            transitions = array::append(transitions ?? [], {
                from_state: $staged.qualification,
                to_state: "TO_CONFIRM",
                triggered_by: $who.operator,
                reason: $reason,
                transitioned_at: $now
            }));
        IF $updated == NONE {
            RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_staged_item" });
        };
    };

    RETURN fn::result_ok(true);
} COMMENT "Résout une anomalie en quarantaine ; réservé au steward_admin (ou à la session système) lu dans la session ; l'article lié, corrigé (code-barres, unité), repasse en TO_CONFIRM"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
