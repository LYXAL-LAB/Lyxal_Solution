-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_list                                               │
-- │  Liste et filtre les occurrences d'erreurs récentes par module/code      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_occurrence_list(
    $params: object
) {
    LET $code = $params.code;
    LET $source_module = $params.source_module;
    LET $limit_count = $params.limit;

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

    LET $list = SELECT * FROM error_occurrence 
                 WHERE ($clean_code = NONE OR code = $clean_code)
                   AND ($clean_mod = NONE OR source_module = $clean_mod)
                 ORDER BY occurred_at DESC 
                 LIMIT $lim;

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les occurrences d'erreurs journalisées au format universel LyxalResult";
