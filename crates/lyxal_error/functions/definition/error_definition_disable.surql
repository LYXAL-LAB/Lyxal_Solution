-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_disable                                           │
-- │  Désactive une définition d'erreur canonique sans suppression physique │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_disable(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_target = $params.code ?? $params.id ?? $params.code_or_id;

    IF $raw_target == NONE OR string::len(string::trim(<string>$raw_target)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code" });
    };

    LET $val = string::trim(<string>$raw_target);
    LET $clean_code = string::uppercase($val);
    LET $existing = SELECT VALUE id FROM error_definition 
                     WHERE id = $val 
                        OR id = type::thing("error_definition", $clean_code) 
                        OR code = $clean_code 
                     LIMIT 1;

    IF array::len($existing) == 0 {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $language, { code: $val });
    };

    UPDATE $existing[0] SET enabled = false, updated_at = time::now();
    RETURN fn::result_ok({ disabled: true, id: <string>$existing[0] });
} COMMENT "Désactive logiquement une définition d'erreur canonique du catalogue";
