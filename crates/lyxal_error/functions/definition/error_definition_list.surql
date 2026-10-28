-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_list                                              │
-- │  Liste les définitions d'erreurs filtrées par module ou catégorie      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_list(
    $params: object
) {
    LET $module = $params.module;
    LET $category = $params.category;
    LET $domain = $params.domain;
    LET $enabled_only = IF $params.enabled_only != NONE { $params.enabled_only } ELSE { true };
    LET $limit = IF $params.limit != NONE { $params.limit } ELSE { 50 };
    LET $start = IF $params.start != NONE { $params.start } ELSE { 0 };

    LET $clean_mod = IF $module != NONE AND string::len(string::trim($module)) > 0 {
        string::lowercase(string::trim($module))
    } ELSE {
        NONE
    };

    LET $clean_cat = IF $category != NONE AND string::len(string::trim($category)) > 0 {
        string::lowercase(string::trim($category))
    } ELSE {
        NONE
    };

    LET $clean_dom = IF $domain != NONE AND string::len(string::trim($domain)) > 0 {
        string::lowercase(string::trim($domain))
    } ELSE {
        NONE
    };

    LET $list = SELECT * FROM error_definition 
                 WHERE ($clean_mod = NONE OR module = $clean_mod)
                   AND ($clean_cat = NONE OR category = $clean_cat)
                   AND ($clean_dom = NONE OR domain = $clean_dom)
                   AND ($enabled_only = false OR enabled = true)
                 ORDER BY code ASC
                 LIMIT $limit
                 START $start;

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les définitions d'erreurs du catalogue canonique au format universel";
