-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_list                                                 │
-- │  Liste les règles de correspondance filtrées par fournisseur            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_list(
    $params: any
) {
    LET $p = IF type::is::object($params) { $params } ELSE IF type::is::string($params) { { provider: $params } } ELSE { {} };
    LET $provider = $p.provider;
    LET $service = $p.service;
    LET $enabled_only = IF $p.enabled_only != NONE { $p.enabled_only } ELSE { true };
    LET $limit = IF $p.limit != NONE { $p.limit } ELSE { 50 };
    LET $start = IF $p.start != NONE { $p.start } ELSE { 0 };

    LET $clean_provider = IF $provider != NONE AND string::len(string::trim($provider)) > 0 {
        string::lowercase(string::trim($provider))
    } ELSE {
        NONE
    };

    LET $clean_service = IF $service != NONE AND string::len(string::trim($service)) > 0 {
        string::lowercase(string::trim($service))
    } ELSE {
        NONE
    };

    LET $list = SELECT * FROM error_external_mapping 
                 WHERE ($clean_provider = NONE OR provider = $clean_provider)
                   AND ($clean_service = NONE OR service = $clean_service)
                   AND ($enabled_only = false OR enabled = true)
                 ORDER BY priority ASC, provider ASC
                 LIMIT $limit
                 START $start;

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les règles de correspondance externes au format universel";
