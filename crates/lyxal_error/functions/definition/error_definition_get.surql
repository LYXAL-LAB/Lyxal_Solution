-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/definition/error_definition_get.surql
-- Fonction : fn::error_definition_get
--
-- Renvoie une définition d'erreur par son code (active ou non).
--
-- Paramètres
--   code (requis), language
--
-- Valeur renvoyée : fn::result_ok(définition)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_DEFINITION_NOT_FOUND : code inconnu
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_definition_get(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }], required: true },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $definition = (SELECT * FROM error_definition WHERE code = $p.code LIMIT 1)[0];
    IF $definition IS NONE { RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $p.language, { code: $p.code }); };
    RETURN fn::result_ok($definition);
}
COMMENT "Renvoie une définition d'erreur par son code (active ou non)."
PERMISSIONS FULL;
