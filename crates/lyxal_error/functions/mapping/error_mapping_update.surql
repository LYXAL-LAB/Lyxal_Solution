-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/mapping/error_mapping_update.surql
-- Fonction : fn::error_mapping_update
--
-- Met à jour une correspondance externe : seuls les champs transmis changent
-- (fournisseur et code externe immuables).
--
-- Paramètres
--   mapping_id (requis)
--   service, matcher, definition_code, priority, external_http_status, description, retryable_override, enabled, metadata, language
--
-- Valeur renvoyée : fn::result_ok(correspondance)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_MAPPING_NOT_FOUND : correspondance inconnue
--   ERROR_DEFINITION_NOT_FOUND : definition_code inconnu
--   ERROR_MAPPING_ALREADY_EXISTS : la modification crée un doublon
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_mapping_update(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        mapping_id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["error_external_mapping"] } }], required: true },
        service: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        matcher: { pipeline: [{ rule: "enum", options: { allowed: ["exact", "prefix", "contains", "http_status"], case_sensitive: false } }] },
        definition_code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }] },
        priority: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
        external_http_status: { pipeline: [{ rule: "integer", options: { min_value: 100, max_value: 599 } }] },
        description: { pipeline: [{ rule: "optional_string", options: { max_length: 1000 } }] },
        retryable_override: { pipeline: [{ rule: "boolean" }] },
        enabled: { pipeline: [{ rule: "boolean" }] },
        metadata: { pipeline: [{ rule: "is_object" }] },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $current = (SELECT * FROM $p.mapping_id)[0];
    IF $current IS NONE { RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $p.language, { mapping_id: $p.mapping_id }); };
    LET $definition = IF $p.definition_code IS NONE { NONE } ELSE { (SELECT VALUE id FROM error_definition WHERE code = $p.definition_code LIMIT 1)[0] };
    IF $p.definition_code IS NOT NONE AND $definition IS NONE {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $p.language, { code: $p.definition_code });
    };
    LET $provider = $current.provider;
    LET $service = $p.service ?? $current.service;
    LET $external_code = $current.external_code;
    LET $matcher = $p.matcher ?? $current.matcher;
    LET $exclude = $current.id;
    IF array::len(SELECT VALUE id FROM error_external_mapping
            WHERE provider = $provider AND service = $service AND external_code = $external_code AND matcher = $matcher AND id != $exclude LIMIT 1) > 0 {
        RETURN fn::error_result("ERROR_MAPPING_ALREADY_EXISTS", $p.language, { provider: $provider, service: $service, external_code: $external_code, matcher: $matcher });
    };
    LET $changes = object::extend(
        object::from_entries(array::filter(object::entries($p), |$entry| $entry[0] NOT IN ["mapping_id", "definition_code", "language"] AND $entry[1] IS NOT NONE)),
        IF $definition IS NONE { {} } ELSE { { definition: $definition } }
    );
    LET $updated = UPDATE ONLY $current.id MERGE $changes;
    IF $updated IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_external_mapping" }); };
    RETURN fn::result_ok($updated);
}
COMMENT "Met à jour une correspondance externe : seuls les champs transmis changent (fournisseur et code externe immuables)."
PERMISSIONS FULL;
