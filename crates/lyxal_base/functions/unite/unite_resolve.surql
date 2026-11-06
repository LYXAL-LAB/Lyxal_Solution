-- ============================================================================
-- FONCTION : fn::base_unite_resolve
-- MODULE   : lyxal_base
-- RÔLE     : Résolution d'un bloc de codes bruts vers les unités du référentiel
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            codes: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 500 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };

    -- Codes bruts sans espaces périphériques (moteur du Core), cherchés en majuscules
    LET $pairs = array::distinct($report.value.codes).map(|$raw| { raw: $raw, key: fn::sanitize_uppercase(fn::sanitize_trim($raw)) });

    -- Code Lyxal d'abord, puis code d'échange (UNECE_REC20 avant UNECE_REC21)
    LET $rows = SELECT
        raw,
        (SELECT code, (enabled AND type.enabled == true) AS usable FROM base_unite WHERE code = $parent.key LIMIT 1)[0] AS direct,
        (SELECT unite.code AS code, (unite.enabled AND unite.type.enabled == true) AS usable FROM base_unite_code WHERE code = $parent.key ORDER BY norme LIMIT 1)[0] AS exchange
        FROM $pairs;

    RETURN fn::result_ok(object::from_entries(
        $rows.filter(|$row| $row.direct != NONE OR $row.exchange != NONE).map(|$row| [$row.raw, $row.direct ?? $row.exchange])
    ));
} COMMENT "Résout un bloc de codes bruts (500 au plus) par code Lyxal puis par code d'échange normalisé ; renvoie { <brut>: { code, usable } }, sans entrée pour un code inconnu";
