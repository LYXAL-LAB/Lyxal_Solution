-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/occurrence/error_occurrence_list.surql
-- Fonction : fn::error_occurrence_list
--
-- Liste les occurrences d'erreurs, filtrées par code et module source, de la
-- plus récente à la plus ancienne.
--
-- Paramètres
--   code, source_module, limit (1 à 500, défaut 50), start (défaut 0), language
--
-- Valeur renvoyée : fn::result_ok([occurrence])
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_occurrence_list(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }] },
        source_module: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 50 }, start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    RETURN fn::result_ok(SELECT * FROM error_occurrence
        WHERE ($p.code IS NONE OR code = $p.code)
          AND ($p.source_module IS NONE OR source_module = $p.source_module)
        ORDER BY occurred_at DESC
        LIMIT $p.limit
        START $p.start);
}
COMMENT "Liste les occurrences d'erreurs, filtrées par code et module source, de la plus récente à la plus ancienne."
PERMISSIONS FULL;
