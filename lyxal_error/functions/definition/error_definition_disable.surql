-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_disable                                           │
-- │  Désactive une définition d'erreur canonique sans suppression physique │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_definition_disable(
    $code_or_id: option<string>
) {
    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $existing = SELECT VALUE id FROM error_definition WHERE id = $val OR code = string::uppercase($val) LIMIT 1;

    IF array::len($existing) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $val });
    };

    UPDATE $existing[0] SET enabled = false, updated_at = time::now();
    RETURN fn::result_ok({ disabled: true, id: $existing[0] });
} COMMENT "Désactive logiquement une définition d'erreur canonique du catalogue";
