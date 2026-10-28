-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_list                                              │
-- │  Liste les définitions d'erreurs filtrées par module ou catégorie      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_list(
    $params: any
) {
    LET $p = IF type::is::object($params) { $params } ELSE { {} };
    LET $module = $p.module;
    LET $category = $p.category;
    LET $domain = $p.domain;
    LET $enabled_only = IF $p.enabled_only != NONE { $p.enabled_only } ELSE { true };
    LET $limit = IF $p.limit != NONE { $p.limit } ELSE { 50 };
    LET $start = IF $p.start != NONE { $p.start } ELSE { 0 };

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
