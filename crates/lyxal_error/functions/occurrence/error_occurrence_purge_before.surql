-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_purge_before                                      │
-- │  Purge technique des anciennes occurrences antérieures à une date       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_occurrence_purge_before(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_dt = IF type::is::object($params) {
        $params.before_date ?? $params.before
    } ELSE {
        $params
    };

    LET $before_date = IF type::is::datetime($raw_dt) {
        $raw_dt
    } ELSE IF type::is::string($raw_dt) AND string::len($raw_dt) > 0 {
        <datetime>$raw_dt
    } ELSE {
        NONE
    };

    IF $before_date == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "before_date" });
    };

    LET $deleted = DELETE error_occurrence WHERE occurred_at < $before_date RETURN BEFORE;
    LET $count = array::len($deleted);

    RETURN fn::result_ok({ purged: true, before: <string>$before_date, count: $count });
} COMMENT "Purge les anciennes occurrences d'erreurs antérieures à une date donnée (rétention technique)";
