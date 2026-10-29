-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_get                                               │
-- │  Lecture d'une définition d'erreur par son ID ou code (Admin)           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_get(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_target = $params.code ?? $params.id ?? $params.code_or_id;

    IF $raw_target == NONE OR string::len(string::trim(<string>$raw_target)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code" });
    };

    LET $val = string::trim(<string>$raw_target);
    LET $clean_code = string::uppercase($val);
    LET $res = SELECT * FROM error_definition 
                WHERE id = $val 
                   OR id = type::record("error_definition", $clean_code) 
                   OR code = $clean_code 
                LIMIT 1;

    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $language, { code: $val });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une définition d'erreur canonique au format universel";
