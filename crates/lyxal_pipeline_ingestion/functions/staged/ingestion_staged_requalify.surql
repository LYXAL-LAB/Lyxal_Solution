-- ============================================================================
-- FONCTION : fn::ingestion_staged_requalify
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Requalification auditable d'un article en staging par le Data Steward
-- APPEL    : externe (console Data Steward), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_requalify($params: object) {
    LET $fallback_language = IF type::is_string($params.language) { $params.language } ELSE { NONE };

    -- 1. Habilitation : permission de la session lyxal_auth (jamais dans les paramètres)
    IF !fn::auth_has_permission({ permission: "ingestion.manifest.approve" }) {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $fallback_language, { permission: "ingestion.manifest.approve" });
    };
    LET $operator = fn::ingestion_operator({});

    -- 2. Entrées (la justification est contrôlée à part : code métier dédié)
    LET $report = fn::validation_object_execute($params, {
        fields: {
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_staged_item" } }], required: true },
            new_qualification: { pipeline: [{ rule: "enum", options: { allowed: ["VERIFIED", "TO_CONFIRM", "REJECTED"], case_sensitive: false } }], required: true },
            justification: { pipeline: [] },
            proof: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $fallback_language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $justif = fn::validation_required_string($p.justification, 10, 2000);
    IF !$justif.valid {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $p.language, { field: "justification", reason: $justif.code, min_required: 10 });
    };
    LET $target = string::uppercase($p.new_qualification);

    -- 3. Article en staging
    LET $cur = (SELECT qualification FROM ONLY $p.item_id);
    IF $cur == NONE {
        RETURN fn::error_result("INGESTION_ITEM_NOT_FOUND", $p.language, { item_id: <string> record::id($p.item_id) });
    };
    LET $sealed_by = (SELECT VALUE batch.sealed_manifest FROM ONLY $p.item_id);
    IF $sealed_by != NONE {
        RETURN fn::error_result("INGESTION_STAGED_ITEM_SEALED", $p.language, { item_id: <string> record::id($p.item_id), manifest_ref: $sealed_by });
    };

    -- 4. Règle d'or : preuve commerciale authentifiée obligatoire pour VERIFIED
    IF $target == "VERIFIED" {
        IF (SELECT VALUE unite_reference FROM ONLY $p.item_id) == NONE {
            RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", $p.language, { item_id: <string> record::id($p.item_id), field: "unite_reference" });
        };
        IF $p.proof == NONE {
            RETURN fn::error_result("INGESTION_PROOF_MISSING", $p.language, { item_id: <string> record::id($p.item_id) });
        };
        LET $proof = fn::validation_object_execute($p.proof, {
            fields: {
                proof_type: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
                proof_reference: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 255 } }], required: true },
                source_authority: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 255 } }], required: true }
            },
            unknown_keys: "keep"
        }, 10);
        IF !$proof.valid {
            RETURN fn::error_result("INGESTION_PROOF_INVALID", $p.language, { fields: $proof.by_field });
        };
        IF !fn::validation_enum($proof.value.proof_type, ["CERTIFIED_MANUFACTURER_EDI", "SIGNED_VENDOR_CATALOG", "OFFICIAL_TARIFF_CERTIFICATE", "STEWARD_DOCUMENTED_VALIDATION"], false).valid {
            RETURN fn::error_result("INGESTION_PROOF_TYPE_UNKNOWN", $p.language, { proof_type: $proof.value.proof_type });
        };
    };

    -- 5. Transition journalisée ; l'approbation n'accompagne que VERIFIED
    LET $now = time::now();
    LET $is_verified = $target == "VERIFIED";
    LET $updated = (UPDATE ONLY $p.item_id SET
        qualification = $target,
        qualification_reason = $justif.value,
        commercial_proof = IF $is_verified { $p.proof } ELSE { commercial_proof },
        is_approved = IF $is_verified { true } ELSE { is_approved },
        approved_by = IF $is_verified { $operator } ELSE { approved_by },
        approved_at = IF $is_verified { $now } ELSE { approved_at },
        transitions = array::append(transitions ?? [], {
            from_state: $cur.qualification,
            to_state: $target,
            triggered_by: $operator,
            reason: $justif.value,
            transitioned_at: $now,
            proof_reference: IF $is_verified { $p.proof.proof_reference } ELSE { NONE }
        }));
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_staged_item" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Requalifie un article en staging ; réservé à la permission ingestion.manifest.approve (ou à la session système), opérateur lu dans la session ; VERIFIED exige une unité du référentiel et une preuve commerciale, et enregistre l'approbation"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
