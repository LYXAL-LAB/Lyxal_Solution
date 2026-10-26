-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_create                                               │
-- │  Création d'un mapping entre erreur externe et code Lyxal canonique     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_mapping_create(
    $provider: option<string>,
    $service: option<string>,
    $external_code: option<string>,
    $matcher: option<string>,
    $definition_id: option<record<error_definition>>,
    $priority: option<int>
) {
    IF $provider == NONE OR string::len(string::trim($provider)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "provider" });
    };
    IF $external_code == NONE OR string::len(string::trim($external_code)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "external_code" });
    };
    IF $definition_id == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "definition_id" });
    };

    LET $clean_provider = string::lowercase(string::trim($provider));
    LET $clean_service = IF $service != NONE { string::lowercase(string::trim($service)) } ELSE { NONE };
    LET $clean_ext_code = string::trim($external_code);
    LET $m = IF $matcher != NONE { string::lowercase(string::trim($matcher)) } ELSE { "exact" };
    LET $p = IF $priority != NONE { $priority } ELSE { 100 };

    LET $created = CREATE ONLY error_external_mapping CONTENT {
        provider: $clean_provider,
        service: $clean_service,
        external_code: $clean_ext_code,
        matcher: $m,
        definition: $definition_id,
        priority: $p,
        enabled: true,
        created_at: time::now()
    };

    RETURN fn::result_ok($created);
} COMMENT "Enregistre une règle de correspondance d'erreur externe au format universel";
