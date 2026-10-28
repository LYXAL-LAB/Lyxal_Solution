-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_get                                                │
-- │  Lecture d'une occurrence d'erreur technique par son ID                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_occurrence_get(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = IF type::is::object($params) {
        $params.occurrence_id ?? $params.id
    } ELSE {
        $params
    };

    LET $occurrence_id = IF type::is::record($raw_id) {
        $raw_id
    } ELSE IF type::is::string($raw_id) {
        IF string::starts_with($raw_id, "error_occurrence:") {
            type::thing("error_occurrence", string::slice($raw_id, 17))
        } ELSE {
            type::thing("error_occurrence", $raw_id)
        }
    } ELSE {
        NONE
    };

    IF $occurrence_id == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "occurrence_id" });
    };

    LET $res = SELECT * FROM $occurrence_id;
    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_OCCURRENCE_NOT_FOUND", $language, { occurrence_id: $occurrence_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une occurrence d'erreur au format universel LyxalResult";
