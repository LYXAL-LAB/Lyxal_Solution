-- ============================================================================
-- FONCTION : fn::catalogue_type_list
-- MODULE   : lyxal_catalogue
-- RÔLE     : Liste des types fondamentaux du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_type_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            enabled: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $enabled = $p.enabled;
    LET $records = IF $enabled != NONE {
        SELECT * FROM catalogue_type WHERE enabled = $enabled ORDER BY code ASC
    } ELSE {
        SELECT * FROM catalogue_type ORDER BY code ASC
    };
    RETURN fn::result_ok($records);
} COMMENT "Liste les types fondamentaux d'éléments du catalogue universel";
