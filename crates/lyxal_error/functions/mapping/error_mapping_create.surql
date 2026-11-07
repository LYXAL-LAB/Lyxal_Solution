-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/mapping/error_mapping_create.surql
-- Fonction : fn::error_mapping_create
--
-- Crée une correspondance entre une erreur externe (fournisseur, service,
-- code) et une définition canonique.
--
-- Paramètres
--   provider (requis), external_code (requis), definition_code (requis)
--   service, matcher (exact | prefix | contains | http_status, défaut exact), priority (défaut 100, plus petit = évalué en premier)
--   external_http_status (100 à 599), description, retryable_override, metadata, language
--
-- Valeur renvoyée : fn::result_ok(correspondance)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_DEFINITION_NOT_FOUND : definition_code inconnu
--   ERROR_MAPPING_ALREADY_EXISTS : même fournisseur, service, code et mode déjà enregistrés
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_mapping_create(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        provider: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }], required: true },
        service: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        external_code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 500 } }], required: true },
        matcher: { pipeline: [{ rule: "enum", options: { allowed: ["exact", "prefix", "contains", "http_status"], case_sensitive: false } }], default: "exact" },
        definition_code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }], required: true },
        priority: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 100 },
        external_http_status: { pipeline: [{ rule: "integer", options: { min_value: 100, max_value: 599 } }] },
        description: { pipeline: [{ rule: "optional_string", options: { max_length: 1000 } }] },
        retryable_override: { pipeline: [{ rule: "boolean" }] },
        metadata: { pipeline: [{ rule: "is_object" }], default: {} },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $definition = (SELECT VALUE id FROM error_definition WHERE code = $p.definition_code LIMIT 1)[0];
    IF $definition IS NONE { RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $p.language, { code: $p.definition_code }); };
    LET $provider = $p.provider;
    LET $service = $p.service;
    LET $external_code = $p.external_code;
    LET $matcher = $p.matcher;
    LET $exclude = NONE;
    IF array::len(SELECT VALUE id FROM error_external_mapping
            WHERE provider = $provider AND service = $service AND external_code = $external_code AND matcher = $matcher AND id != $exclude LIMIT 1) > 0 {
        RETURN fn::error_result("ERROR_MAPPING_ALREADY_EXISTS", $p.language, { provider: $provider, service: $service, external_code: $external_code, matcher: $matcher });
    };
    LET $created = CREATE ONLY error_external_mapping CONTENT {
        provider: $provider,
        service: $service,
        external_code: $external_code,
        matcher: $matcher,
        definition: $definition,
        priority: $p.priority,
        external_http_status: $p.external_http_status,
        description: $p.description,
        retryable_override: $p.retryable_override,
        metadata: $p.metadata
    };
    IF $created IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_external_mapping" }); };
    RETURN fn::result_ok($created);
}
COMMENT "Crée une correspondance entre une erreur externe (fournisseur, service, code) et une définition canonique."
PERMISSIONS FULL;
