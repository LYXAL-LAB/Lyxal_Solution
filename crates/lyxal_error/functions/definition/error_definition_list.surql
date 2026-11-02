-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/definition/error_definition_list.surql
-- Fonction : fn::error_definition_list
--
-- Liste les définitions d'erreurs, filtrées par module, domaine, catégorie
-- ou sévérité, triées par code.
--
-- Paramètres
--   module, domain, category, severity, enabled_only (défaut true), limit (1 à 500, défaut 50), start (défaut 0), language
--
-- Valeur renvoyée : fn::result_ok([définition])
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_definition_list(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        module: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        domain: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        category: { pipeline: [{ rule: "enum", options: { allowed: ["validation", "business", "authentication", "authorization", "not_found", "conflict", "rate_limit", "dependency", "network", "timeout", "internal"], case_sensitive: false } }] },
        severity: { pipeline: [{ rule: "enum", options: { allowed: ["info", "warning", "error", "critical"], case_sensitive: false } }] },
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
    RETURN fn::result_ok(SELECT * FROM error_definition
        WHERE ($p.module IS NONE OR module = $p.module)
          AND ($p.domain IS NONE OR domain = $p.domain)
          AND ($p.category IS NONE OR category = $p.category)
          AND ($p.severity IS NONE OR severity = $p.severity)
          AND ($p.enabled_only == false OR enabled = true)
        ORDER BY code ASC
        LIMIT $p.limit
        START $p.start);
}
COMMENT "Liste les définitions d'erreurs, filtrées par module, domaine, catégorie ou sévérité, triées par code."
PERMISSIONS FULL;
