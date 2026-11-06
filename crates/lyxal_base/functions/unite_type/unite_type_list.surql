-- ============================================================================
-- FONCTION : fn::base_unite_type_list
-- MODULE   : lyxal_base
-- RÔLE     : Liste paginée des types d'unités
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            enabled: { pipeline: [{ rule: "boolean" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $records = IF $p.enabled != NONE {
        SELECT * FROM base_unite_type WHERE enabled = $p.enabled ORDER BY code ASC LIMIT $p.limit START $p.start
    } ELSE {
        SELECT * FROM base_unite_type ORDER BY code ASC LIMIT $p.limit START $p.start
    };
    RETURN fn::result_ok($records);
} COMMENT "Liste les types d'unités par code, avec pagination bornée et filtre facultatif d'activation";
