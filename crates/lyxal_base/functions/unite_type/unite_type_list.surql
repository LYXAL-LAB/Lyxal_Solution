-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_type_list                                                │
-- │  Liste paginée des types d'unités de mesure avec filtrage d'état        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_type_list($params: object) {
    LET $enabled = $params.enabled;
    LET $raw_limit = IF $params.limit != NONE { $params.limit } ELSE { 50 };
    LET $raw_start = IF $params.start != NONE { $params.start } ELSE { 0 };
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    -- Validation de la pagination
    IF $raw_limit < 1 OR $raw_limit > 200 OR $raw_start < 0 {
        RETURN fn::error_result("BASE_PAGINATION_INVALID", $language, { limit: $raw_limit, start: $raw_start });
    };

    LET $limit = <int> $raw_limit;
    LET $start = <int> $raw_start;

    LET $records = IF $enabled != NONE {
        SELECT * FROM base_unite_type WHERE enabled = $enabled ORDER BY code ASC LIMIT $limit START $start
    } ELSE {
        SELECT * FROM base_unite_type ORDER BY code ASC LIMIT $limit START $start
    };

    RETURN fn::result_ok($records);
} COMMENT "Liste les types d'unités avec pagination bornée et filtre facultatif d'activation";
