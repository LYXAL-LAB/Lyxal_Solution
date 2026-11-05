-- ============================================================================
-- FONCTION : fn::ingestion_rule_family_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Ajout ou mise à jour d'une famille de produits (console Data Steward)
-- APPEL    : externe, entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_family_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }], required: true },
            label: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 255 } }], required: true },
            keywords: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, max_length: 128 } }], default: [] },
            standard_unit: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 32 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            code: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            label: { pipeline: [{ rule: "trim" }] },
            standard_unit: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 20);

    LET $saved = (UPSERT ONLY type::record("ingestion_family_rule", $p.code) CONTENT {
        code: $p.code,
        label: $p.label,
        keywords: $p.keywords,
        standard_unit: $p.standard_unit,
        updated_at: time::now()
    });
    IF $saved == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_family_rule" });
    };

    RETURN fn::result_ok($p.code);
} COMMENT "Ajoute ou met à jour une famille de produits (code, libellé, mots-clés, unité standard) sans recompilation du moteur Rust";
