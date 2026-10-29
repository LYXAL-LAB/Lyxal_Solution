-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_get                                                │
-- │  Lecture d'une occurrence d'erreur technique par son ID                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_occurrence_get(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = $params.occurrence_id ?? $params.id;
    LET $raw_str = IF $raw_id != NONE { string::trim(<string>$raw_id) } ELSE { "" };
    LET $id_part = string::replace($raw_str, "error_occurrence:", "");

    LET $occurrence_id = IF type::is_record($raw_id) {
        $raw_id
    } ELSE IF string::len($id_part) > 0 {
        type::record("error_occurrence", $id_part)
    } ELSE {
        NONE
    };

    IF $occurrence_id == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "occurrence_id" });
    };

    LET $res = SELECT * FROM error_occurrence WHERE id = $occurrence_id;
    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_OCCURRENCE_NOT_FOUND", $language, { occurrence_id: <string>$occurrence_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une occurrence d'erreur au format universel LyxalResult";
