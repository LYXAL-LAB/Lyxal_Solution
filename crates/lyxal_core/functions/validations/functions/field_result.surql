-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_field_result
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_field_result(
    $field: string,
    $value: option<any>,
    $errors: array<object>,
    $warnings: array<object>
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    RETURN {
        field: $clean_field,
        valid: array::len($errors) = 0,
        value: $value,
        errors: $errors,
        warnings: $warnings
    };
}
COMMENT "Construit le résultat complet d'un champ."
PERMISSIONS FULL;
