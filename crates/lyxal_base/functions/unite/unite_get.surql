-- ============================================================================
-- FONCTION : fn::base_unite_get
-- MODULE   : lyxal_base
-- RÔLE     : Lecture d'une unité par identifiant ou par code
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }] },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }] },
            fetch_type: { pipeline: [{ rule: "boolean" }], default: false },
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

    LET $record_id = IF $p.id != NONE { $p.id } ELSE { type::record("base_unite", $p.code) };
    -- usable : unité et type actifs, seule règle d'emploi d'une unité dans un nouveau document
    LET $found = IF $p.fetch_type {
        (SELECT *, (enabled AND type.enabled == true) AS usable, type.* AS type_detail, (SELECT norme, code FROM base_unite_code WHERE unite = $parent.id ORDER BY norme, code) AS codes FROM ONLY $record_id)
    } ELSE {
        (SELECT *, (enabled AND type.enabled == true) AS usable, (SELECT norme, code FROM base_unite_code WHERE unite = $parent.id ORDER BY norme, code) AS codes FROM ONLY $record_id)
    };
    IF $found == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: <string> $record_id });
    };
    LET $labelled = fn::base_libelle_attach([$found], "unite", $p.locale ?? $p.language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $p.language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records[0]);
} COMMENT "Lit une unité par son identifiant (base_unite:<CODE>) ou par son code ; libellé rendu dans la langue demandée (locale, par défaut language) ; usable indique si l'unité et son type sont actifs, codes liste ses codes d'échange normalisés";
