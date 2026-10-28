-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_disable                                           │
-- │  Désactive une définition d'erreur canonique sans suppression physique │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_disable(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $code_or_id = IF type::is::string($params) {
        $params
    } ELSE IF type::is::object($params) {
        $params.code_or_id ?? $params.id ?? $params.code
    } ELSE {
        NONE
    };

    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $clean_code = string::uppercase($val);
    LET $existing = SELECT VALUE id FROM error_definition 
                     WHERE id = $val 
                        OR id = type::thing("error_definition", $clean_code) 
                        OR code = $clean_code 
                     LIMIT 1;

    IF array::len($existing) == 0 {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $language, { code_or_id: $val });
    };

    UPDATE $existing[0] SET enabled = false, updated_at = time::now();
    RETURN fn::result_ok({ disabled: true, id: $existing[0] });
} COMMENT "Désactive logiquement une définition d'erreur canonique du catalogue";
