-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/definition/error_definition_create.surql
-- Fonction : fn::error_definition_create
--
-- Crée une définition d'erreur canonique (identifiant
-- error_definition:<CODE>). Le code doit commencer par le nom du module en
-- majuscules suivi de « _ » (tirets du module remplacés par « _ »).
--
-- Paramètres
--   code (requis, ^[A-Z][A-Z0-9_]+$), module (requis, ^[a-z][a-z0-9_-]+$), message (requis)
--   domain, category (défaut business), severity (défaut error), http_status (400 à 599)
--   translations, default_language (défaut en), retryable (défaut false), log_occurrence (défaut true), documentation, metadata, enabled (défaut true), language
--
-- Valeur renvoyée : fn::result_ok(définition)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_DEFINITION_CODE_PREFIX_MISMATCH : le code ne commence pas par le module
--   ERROR_DEFINITION_ALREADY_EXISTS : code déjà défini
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_definition_create(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }], required: true },
        module: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }], required: true },
        domain: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        message: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 1000 } }], required: true },
        category: { pipeline: [{ rule: "enum", options: { allowed: ["validation", "business", "authentication", "authorization", "not_found", "conflict", "rate_limit", "dependency", "network", "timeout", "internal"], case_sensitive: false } }], default: "business" },
        severity: { pipeline: [{ rule: "enum", options: { allowed: ["info", "warning", "error", "critical"], case_sensitive: false } }], default: "error" },
        http_status: { pipeline: [{ rule: "integer", options: { min_value: 400, max_value: 599 } }] },
        translations: { pipeline: [{ rule: "is_object" }], default: {} },
        default_language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "en" },
        retryable: { pipeline: [{ rule: "boolean" }], default: false },
        log_occurrence: { pipeline: [{ rule: "boolean" }], default: true },
        documentation: { pipeline: [{ rule: "is_object" }], default: {} },
        metadata: { pipeline: [{ rule: "is_object" }], default: {} },
        enabled: { pipeline: [{ rule: "boolean" }], default: true },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !string::starts_with($p.code, string::replace(string::uppercase($p.module), "-", "_") + "_") {
        RETURN fn::error_result("ERROR_DEFINITION_CODE_PREFIX_MISMATCH", $p.language, { code: $p.code, module: $p.module });
    };
    LET $id = type::record("error_definition", $p.code);
    IF record::exists($id) OR array::len(SELECT VALUE id FROM error_definition WHERE code = $p.code LIMIT 1) > 0 {
        RETURN fn::error_result("ERROR_DEFINITION_ALREADY_EXISTS", $p.language, { code: $p.code });
    };
    LET $created = CREATE ONLY $id CONTENT {
        code: $p.code,
        module: $p.module,
        domain: $p.domain,
        category: $p.category,
        severity: $p.severity,
        message: $p.message,
        http_status: $p.http_status,
        translations: $p.translations,
        default_language: $p.default_language,
        retryable: $p.retryable,
        log_occurrence: $p.log_occurrence,
        documentation: $p.documentation,
        metadata: $p.metadata,
        enabled: $p.enabled
    };
    IF $created IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_definition" }); };
    RETURN fn::result_ok($created);
}
COMMENT "Crée une définition d'erreur canonique (identifiant error_definition:<CODE>). Le code doit commencer par le nom du module en majuscules suivi de « _ » (tirets du module remplacés par « _ »)."
PERMISSIONS FULL;
