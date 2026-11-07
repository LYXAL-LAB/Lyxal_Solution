-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/definition/error_definition_update.surql
-- Fonction : fn::error_definition_update
--
-- Met à jour une définition d'erreur : seuls les champs transmis changent
-- (le code et le module sont immuables).
--
-- Paramètres
--   code (requis)
--   message, domain, category, severity, http_status, translations, default_language, retryable, log_occurrence, documentation, metadata, enabled, language
--
-- Valeur renvoyée : fn::result_ok(définition)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_DEFINITION_NOT_FOUND : code inconnu
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_definition_update(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }], required: true },
        domain: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        message: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 1000 } }] },
        category: { pipeline: [{ rule: "enum", options: { allowed: ["validation", "business", "authentication", "authorization", "not_found", "conflict", "rate_limit", "dependency", "network", "timeout", "internal"], case_sensitive: false } }] },
        severity: { pipeline: [{ rule: "enum", options: { allowed: ["info", "warning", "error", "critical"], case_sensitive: false } }] },
        http_status: { pipeline: [{ rule: "integer", options: { min_value: 400, max_value: 599 } }] },
        translations: { pipeline: [{ rule: "is_object" }] },
        default_language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }] },
        retryable: { pipeline: [{ rule: "boolean" }] },
        log_occurrence: { pipeline: [{ rule: "boolean" }] },
        documentation: { pipeline: [{ rule: "is_object" }] },
        metadata: { pipeline: [{ rule: "is_object" }] },
        enabled: { pipeline: [{ rule: "boolean" }] },
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
    LET $changes = object::from_entries(array::filter(object::entries($p), |$entry| $entry[0] NOT IN ["code", "language"] AND $entry[1] IS NOT NONE));
    LET $updated = UPDATE ONLY $definition.id MERGE $changes;
    IF $updated IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_definition" }); };
    RETURN fn::result_ok($updated);
}
COMMENT "Met à jour une définition d'erreur : seuls les champs transmis changent (le code et le module sont immuables)."
PERMISSIONS FULL;
