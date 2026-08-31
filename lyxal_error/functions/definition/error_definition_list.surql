-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_list                                              │
-- │  Liste les définitions d'erreurs filtrées par module ou catégorie      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_definition_list(
    $module: option<string>,
    $category: option<string>
) {
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

    LET $list = IF $clean_mod != NONE AND $clean_cat != NONE {
        SELECT * FROM error_definition WHERE module = $clean_mod AND category = $clean_cat ORDER BY code ASC
    } ELSE IF $clean_mod != NONE {
        SELECT * FROM error_definition WHERE module = $clean_mod ORDER BY code ASC
    } ELSE IF $clean_cat != NONE {
        SELECT * FROM error_definition WHERE category = $clean_cat ORDER BY code ASC
    } ELSE {
        SELECT * FROM error_definition ORDER BY code ASC
    };

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les définitions d'erreurs du catalogue canonique au format universel";
