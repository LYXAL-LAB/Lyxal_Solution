-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_list                                                     │
-- │  Liste paginée des unités avec double filtrage hiérarchique d'état      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_list($params: object) {
    LET $type = $params.type;
    LET $enabled = $params.enabled;
    LET $for_new_documents = IF $params.for_new_documents != NONE { <bool> $params.for_new_documents } ELSE { false };
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

    -- Règle CTO n°3 : Pour les nouveaux devis/documents, filtrer simultanément base_unite.enabled = true ET base_unite_type.enabled = true
    LET $records = IF $for_new_documents == true {
        IF $type != NONE {
            SELECT * FROM base_unite WHERE type = $type AND enabled = true AND type.enabled = true ORDER BY code ASC LIMIT $limit START $start
        } ELSE {
            SELECT * FROM base_unite WHERE enabled = true AND type.enabled = true ORDER BY code ASC LIMIT $limit START $start
        }
    } ELSE IF $type != NONE AND $enabled != NONE {
        SELECT * FROM base_unite WHERE type = $type AND enabled = $enabled ORDER BY code ASC LIMIT $limit START $start
    } ELSE IF $type != NONE {
        SELECT * FROM base_unite WHERE type = $type ORDER BY code ASC LIMIT $limit START $start
    } ELSE IF $enabled != NONE {
        SELECT * FROM base_unite WHERE enabled = $enabled ORDER BY code ASC LIMIT $limit START $start
    } ELSE {
        SELECT * FROM base_unite ORDER BY code ASC LIMIT $limit START $start
    };

    RETURN fn::result_ok($records);
} COMMENT "Liste les unités avec pagination bornée et double filtrage d'activation unité et type parent";
