-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_create                                               │
-- │  Création d'un mapping entre erreur externe et code Lyxal canonique     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_create(
    $params: object
) {
    LET $provider = $params.provider;
    LET $service = $params.service;
    LET $external_code = $params.external_code;
    LET $matcher = $params.matcher ?? $params.match_type;
    LET $raw_def = $params.definition_id ?? $params.target_code ?? $params.definition;
    LET $priority = $params.priority;
    LET $ext_http_status = $params.external_http_status ?? $params.http_status;
    LET $description = $params.description;
    LET $retryable_override = $params.retryable_override;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $provider == NONE OR string::len(string::trim($provider)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "provider" });
    };
    IF $external_code == NONE OR string::len(string::trim($external_code)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "external_code" });
    };

    LET $clean_str = IF type::is_string($raw_def) { <string>$raw_def } ELSE { "" };
    LET $id_part = IF string::starts_with($clean_str, "error_definition:") {
        string::slice($clean_str, 17)
    } ELSE {
        $clean_str
    };

    LET $def_rec = IF type::is_record($raw_def) {
        $raw_def
    } ELSE IF string::len($id_part) > 0 {
        (SELECT VALUE id FROM error_definition WHERE code = $id_part OR id = type::record("error_definition", $id_part) LIMIT 1)[0]
    } ELSE {
        NONE
    };

    IF $def_rec == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "definition_id" });
    };

    LET $clean_provider = string::lowercase(string::trim($provider));
    LET $clean_service = IF $service != NONE AND string::len(string::trim($service)) > 0 { string::lowercase(string::trim($service)) } ELSE { NONE };
    LET $clean_ext_code = string::trim($external_code);
    LET $m = IF $matcher != NONE AND string::len(string::trim($matcher)) > 0 { string::lowercase(string::trim($matcher)) } ELSE { "exact" };
    LET $p = IF $priority != NONE { $priority } ELSE { 100 };

    LET $created = CREATE ONLY error_external_mapping CONTENT {
        provider: $clean_provider,
        service: $clean_service,
        external_code: $clean_ext_code,
        matcher: $m,
        definition: $def_rec,
        priority: $p,
        external_http_status: $ext_http_status,
        description: $description,
        retryable_override: $retryable_override,
        enabled: true
    };

    RETURN fn::result_ok($created);
} COMMENT "Enregistre une règle de correspondance d'erreur externe au format universel";
