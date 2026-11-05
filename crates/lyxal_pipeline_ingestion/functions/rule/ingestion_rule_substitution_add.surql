-- ============================================================================
-- FONCTION : fn::ingestion_rule_substitution_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Ajout ou mise à jour d'une règle de substitution certifiée (console Data Steward)
-- APPEL    : externe, entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_substitution_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            rule_id: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }], required: true },
            source_mfg: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            source_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            target_mfg: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            target_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            system_scope: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 500 } }], required: true },
            certification_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            certification_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            valid_until: { pipeline: [{ rule: "datetime" }], required: true },
            is_revoked: { pipeline: [{ rule: "boolean" }], default: false },
            revocation_reason: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 2000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            rule_id: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            source_mfg: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            source_ref: { pipeline: [{ rule: "trim" }] },
            target_mfg: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            target_ref: { pipeline: [{ rule: "trim" }] },
            system_scope: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            certification_body: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            certification_ref: { pipeline: [{ rule: "trim" }] }
        },
        unknown_keys: "keep"
    }, 20);

    IF $p.is_revoked AND $p.revocation_reason == NONE {
        RETURN fn::error_result("INGESTION_SUBSTITUTION_RULE_INVALID", $p.language, { rule_id: $p.rule_id, reason: "revocation_reason_required" });
    };

    LET $saved = (UPSERT ONLY type::record("ingestion_substitution_rule", $p.rule_id) CONTENT {
        rule_id: $p.rule_id,
        source_mfg: $p.source_mfg,
        source_ref: $p.source_ref,
        target_mfg: $p.target_mfg,
        target_ref: $p.target_ref,
        system_scope: $p.system_scope,
        certification_body: $p.certification_body,
        certification_ref: $p.certification_ref,
        valid_until: $p.valid_until,
        is_revoked: $p.is_revoked,
        revocation_reason: $p.revocation_reason,
        updated_at: time::now()
    });
    IF $saved == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_substitution_rule" });
    };

    RETURN fn::result_ok($p.rule_id);
} COMMENT "Ajoute ou met à jour une règle de substitution certifiée (source, cible, périmètre, certification, validité) ; une règle révoquée exige son motif";
