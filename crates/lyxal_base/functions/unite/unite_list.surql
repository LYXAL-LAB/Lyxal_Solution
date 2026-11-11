-- ============================================================================
-- FONCTION : fn::base_unite_list
-- MODULE   : lyxal_base
-- RÔLE     : Liste paginée des unités
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            type: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            for_new_documents: { pipeline: [{ rule: "boolean" }], default: false },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Nouveaux documents : unité et type actifs (même règle que usable de fn::base_unite_get)
    LET $records = SELECT * FROM base_unite
        WHERE ($p.type == NONE OR type == $p.type)
          AND IF $p.for_new_documents { enabled AND type.enabled == true } ELSE { $p.enabled == NONE OR enabled == $p.enabled }
        ORDER BY code ASC LIMIT $p.limit START $p.start;
    LET $labelled = fn::base_libelle_attach($records, "unite", $p.locale ?? $p.language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $p.language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records);
} COMMENT "Liste les unités par code, libellé rendu dans la langue demandée (locale, par défaut language), avec pagination bornée, filtres type et activation, ou les seules unités utilisables pour un nouveau document";
