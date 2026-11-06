-- ============================================================================
-- FONCTION : fn::base_unite_create
-- MODULE   : lyxal_base
-- RÔLE     : Création d'une unité de mesure rattachée à un type actif
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }, { rule: "alphanumeric", options: { trim_value: true } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            abreviation: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10 } }], required: true },
            type: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { code: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 40);
    LET $language = $p.language;

    -- Un type inexistant ou inactif ne reçoit pas de nouvelle unité
    LET $parent = (SELECT enabled FROM ONLY $p.type);
    IF $parent == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_INVALID", $language, { type: <string> $p.type });
    };
    IF !$parent.enabled {
        RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, { type: <string> $p.type });
    };

    LET $record_id = type::record("base_unite", $p.code);
    IF record::exists($record_id) {
        RETURN fn::error_result("BASE_UNITE_ALREADY_EXISTS", $language, { code: $p.code });
    };

    LET $created = (CREATE ONLY $record_id CONTENT {
        code: $p.code,
        libelle: $p.libelle,
        abreviation: $p.abreviation,
        type: $p.type,
        enabled: true
    });
    IF $created == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite" });
    };
    RETURN fn::result_ok($created);
} COMMENT "Crée une unité de mesure rattachée à un type d'unité existant et actif";
