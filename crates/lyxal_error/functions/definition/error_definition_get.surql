-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_get                                               │
-- │  Lecture d'une définition d'erreur par son ID ou code (Admin)           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_definition_get(
    $code_or_id: option<string>
) {
    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $res = SELECT * FROM error_definition WHERE id = $val OR code = string::uppercase($val) LIMIT 1;

    IF array::len($res) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $val });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une définition d'erreur canonique au format universel";
