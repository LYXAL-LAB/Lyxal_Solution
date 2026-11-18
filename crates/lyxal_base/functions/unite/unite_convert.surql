-- ============================================================================
-- FONCTION : fn::base_unite_convert
-- MODULE   : lyxal_base
-- RÔLE     : Conversion d'une quantité entre deux unités d'un même type
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_convert($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            quantity: { pipeline: [{ rule: "number", options: { min_value: 0, max_value: 1000000000000000 } }], required: true },
            from: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }, { rule: "alphanumeric", options: { trim_value: true } }], required: true },
            to: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }, { rule: "alphanumeric", options: { trim_value: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { from: { pipeline: [{ rule: "uppercase" }] }, to: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 40);
    LET $language = $p.language;

    -- Les deux unités, avec l'état et l'unité de base de leur type
    LET $from = (SELECT code, type, factor, (enabled AND type.enabled == true) AS usable, type.base_unit AS base_unit FROM ONLY type::record("base_unite", $p.from));
    IF $from == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: string::concat("base_unite:", $p.from) });
    };
    LET $to = (SELECT code, type, factor, (enabled AND type.enabled == true) AS usable, type.base_unit AS base_unit FROM ONLY type::record("base_unite", $p.to));
    IF $to == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: string::concat("base_unite:", $p.to) });
    };

    IF $from.type != $to.type {
        RETURN fn::error_result("BASE_UNITE_TYPE_MISMATCH", $language, { from: $from.code, from_type: <string> $from.type, to: $to.code, to_type: <string> $to.type });
    };
    -- Convertible : unité et type actifs, facteur défini, type doté d'une unité de base
    LET $blocked = array::first([$from, $to].filter(|$unit| !$unit.usable OR $unit.factor == NONE OR $unit.base_unit == NONE));
    IF $blocked != NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_CONVERTIBLE", $language, {
            code: $blocked.code,
            reason: IF !$blocked.usable { "disabled" } ELSE IF $blocked.factor == NONE { "no_factor" } ELSE { "no_base_unit" }
        });
    };

    -- Calcul décimal, sans arrondi : l'appelant arrondit selon son usage
    RETURN fn::result_ok({
        quantity: <decimal> $p.quantity * $from.factor / $to.factor,
        from: $from.code,
        to: $to.code
    });
} COMMENT "Convertit une quantité (nombre de 0 à 10^15) entre deux unités d'un même type, désignées par leur code : quantité × facteur de from ÷ facteur de to, en décimal et sans arrondi ; refus entre deux types (BASE_UNITE_TYPE_MISMATCH) ou si une unité est inactive, sans facteur ou d'un type sans unité de base (BASE_UNITE_NOT_CONVERTIBLE, détail reason)";
