-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_get                                               │
-- │  Lecture d'une définition d'erreur par son ID ou code (Admin)           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_get(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $code_or_id = IF type::is::string($params) {
        $params
    } ELSE IF type::is::object($params) {
        $params.code_or_id ?? $params.code ?? $params.id
    } ELSE {
        NONE
    };

    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $clean_code = string::uppercase($val);
    LET $res = SELECT * FROM error_definition 
                WHERE id = $val 
                   OR id = type::thing("error_definition", $clean_code) 
                   OR code = $clean_code 
                LIMIT 1;

    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $language, { code_or_id: $val });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une définition d'erreur canonique au format universel";
