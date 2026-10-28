-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_map_external                                                  │
-- │  Convertit un code d'erreur fournisseur vers une définition Lyxal       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_map_external(
    $params: object
) {
    LET $provider = $params.provider;
    LET $service = $params.service;
    LET $external_code = $params.external_code;
    LET $http_status = $params.http_status;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $provider == NONE OR string::len(string::trim($provider)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "provider" });
    };
    IF $external_code == NONE OR string::len(string::trim($external_code)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "external_code" });
    };

    LET $clean_provider = string::lowercase(string::trim($provider));
    LET $clean_ext_code = string::trim($external_code);
    LET $clean_service = IF $service != NONE AND string::len(string::trim($service)) > 0 {
        string::lowercase(string::trim($service))
    } ELSE {
        NONE
    };

    LET $mappings = SELECT * FROM error_external_mapping 
                     WHERE provider = $clean_provider 
                       AND enabled = true 
                     ORDER BY priority ASC;

    FOR $m IN $mappings {
        LET $service_match = ($clean_service == NONE) OR ($m.service == NONE) OR ($m.service == $clean_service);
        IF $service_match {
            IF $m.matcher == "exact" AND $clean_ext_code == $m.external_code {
                RETURN fn::result_ok({
                    provider: $m.provider,
                    external_code: $m.external_code,
                    definition: <string>$m.definition,
                    retryable_override: $m.retryable_override,
                    mapping: <string>$m.id
                });
            };
            IF $m.matcher == "prefix" AND string::starts_with($clean_ext_code, $m.external_code) {
                RETURN fn::result_ok({
                    provider: $m.provider,
                    external_code: $m.external_code,
                    definition: <string>$m.definition,
                    retryable_override: $m.retryable_override,
                    mapping: <string>$m.id
                });
            };
            IF $m.matcher == "contains" AND string::contains($clean_ext_code, $m.external_code) {
                RETURN fn::result_ok({
                    provider: $m.provider,
                    external_code: $m.external_code,
                    definition: <string>$m.definition,
                    retryable_override: $m.retryable_override,
                    mapping: <string>$m.id
                });
            };
            IF $m.matcher == "http_status" AND $http_status != NONE AND <string>$http_status == $m.external_code {
                RETURN fn::result_ok({
                    provider: $m.provider,
                    external_code: $m.external_code,
                    definition: <string>$m.definition,
                    retryable_override: $m.retryable_override,
                    mapping: <string>$m.id
                });
            };
        };
    };

    RETURN fn::result_ok(NONE);
} COMMENT "Convertit un code d'erreur fournisseur vers une correspondance canonique Lyxal";
