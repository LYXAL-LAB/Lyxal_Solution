-- ============================================================================
-- FONCTION : fn::base_unite_type_get
-- MODULE   : lyxal_base
-- RÔLE     : Lecture d'un type d'unité par identifiant ou par code
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }] },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }] },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
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
    IF $p.id == NONE AND $p.code == NONE {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", $language, { fields: { id: ["CORE_VALIDATION_REQUIRED"], code: ["CORE_VALIDATION_REQUIRED"] } });
    };

    LET $record_id = IF $p.id != NONE { $p.id } ELSE { type::record("base_unite_type", $p.code) };
    LET $found = (SELECT * FROM ONLY $record_id);
    IF $found == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: <string> $record_id });
    };
    LET $labelled = fn::base_libelle_attach([$found], "unite_type", $p.locale ?? $p.language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $p.language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records[0]);
} COMMENT "Lit un type d'unité par son identifiant (base_unite_type:<CODE>) ou par son code ; libellé rendu dans la langue demandée (locale, par défaut language)";
