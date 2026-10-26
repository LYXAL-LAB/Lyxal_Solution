-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_list                                               │
-- │  Liste et filtre les occurrences d'erreurs récents par module/code      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_occurrence_list(
    $code: option<string>,
    $source_module: option<string>,
    $limit_count: option<int>
) {
    LET $clean_code = IF $code != NONE AND string::len(string::trim($code)) > 0 {
        string::uppercase(string::trim($code))
    } ELSE {
        NONE
    };

    LET $clean_mod = IF $source_module != NONE AND string::len(string::trim($source_module)) > 0 {
        string::lowercase(string::trim($source_module))
    } ELSE {
        NONE
    };

    LET $lim = IF $limit_count != NONE AND $limit_count > 0 { $limit_count } ELSE { 50 };

    LET $list = IF $clean_code != NONE AND $clean_mod != NONE {
        SELECT * FROM error_occurrence WHERE code = $clean_code AND source_module = $clean_mod ORDER BY occurred_at DESC LIMIT $lim
    } ELSE IF $clean_code != NONE {
        SELECT * FROM error_occurrence WHERE code = $clean_code ORDER BY occurred_at DESC LIMIT $lim
    } ELSE IF $clean_mod != NONE {
        SELECT * FROM error_occurrence WHERE source_module = $clean_mod ORDER BY occurred_at DESC LIMIT $lim
    } ELSE {
        SELECT * FROM error_occurrence ORDER BY occurred_at DESC LIMIT $lim
    };

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les occurrences d'erreurs journalisées au format universel LyxalResult";
