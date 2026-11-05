-- ============================================================================
-- FONCTION : fn::ingestion_rule_spec_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Ajout ou mise à jour d'une spécification technique patronne (console Data Steward)
-- APPEL    : externe, entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_spec_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            technical_identity_key: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }], required: true },
            family_code: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }], required: true },
            generic_title: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 255 } }], required: true },
            nominal_dimensions: { pipeline: [{ rule: "is_object" }] },
            tolerances: { pipeline: [{ rule: "is_object" }], default: { length_tol_mm: 5.0, width_tol_mm: 5.0, height_tol_mm: 1.0, weight_tol_pct: 5.0 } },
            nominal_weight: { pipeline: [{ rule: "number", options: { min_value: 0 } }] },
            standard_norm: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            fire_rating: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 64 } }] },
            required_features: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true } }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            technical_identity_key: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            family_code: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] },
            generic_title: { pipeline: [{ rule: "trim" }] },
            standard_norm: { pipeline: [{ rule: "trim" }] },
            fire_rating: { pipeline: [{ rule: "trim" }] }
        },
        unknown_keys: "keep"
    }, 20);

    IF !record::exists(type::record("ingestion_family_rule", $p.family_code)) {
        RETURN fn::error_result("INGESTION_SPEC_INVALID", $p.language, { family_code: $p.family_code, reason: "unknown_family" });
    };

    LET $saved = (UPSERT ONLY type::record("ingestion_specification", $p.technical_identity_key) CONTENT {
        technical_identity_key: $p.technical_identity_key,
        family_code: $p.family_code,
        generic_title: $p.generic_title,
        nominal_dimensions: $p.nominal_dimensions,
        tolerances: $p.tolerances,
        nominal_weight: IF $p.nominal_weight != NONE { <float> $p.nominal_weight } ELSE { NONE },
        standard_norm: $p.standard_norm,
        fire_rating: $p.fire_rating,
        required_features: $p.required_features,
        updated_at: time::now()
    });
    IF $saved == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_specification" });
    };

    RETURN fn::result_ok($p.technical_identity_key);
} COMMENT "Ajoute ou met à jour une spécification technique patronne d'une famille existante (dimensions, tolérances, poids, norme, critères requis)";
