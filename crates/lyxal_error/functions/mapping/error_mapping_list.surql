-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/mapping/error_mapping_list.surql
-- Fonction : fn::error_mapping_list
--
-- Liste les correspondances externes, filtrées par fournisseur et service,
-- triées par priorité puis fournisseur.
--
-- Paramètres
--   provider, service, enabled_only (défaut true), limit (1 à 500, défaut 50), start (défaut 0), language
--
-- Valeur renvoyée : fn::result_ok([correspondance])
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_mapping_list(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        provider: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        service: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        enabled_only: { pipeline: [{ rule: "boolean" }], default: true },
        limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 50 }, start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    RETURN fn::result_ok(SELECT * FROM error_external_mapping
        WHERE ($p.provider IS NONE OR provider = $p.provider)
          AND ($p.service IS NONE OR service = $p.service)
          AND ($p.enabled_only == false OR enabled = true)
        ORDER BY priority ASC, provider ASC
        LIMIT $p.limit
        START $p.start);
}
COMMENT "Liste les correspondances externes, filtrées par fournisseur et service, triées par priorité puis fournisseur."
PERMISSIONS FULL;
