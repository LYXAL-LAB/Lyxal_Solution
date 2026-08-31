-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_error
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_error(
    $field: string,
    $code: string,
    $message: option<string>,
    $details: option<object>
) -> object {
    LET $clean_field = string::trim($field);
    LET $clean_code = string::uppercase(string::trim($code));
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $clean_code = "" { THROW "VALIDATION_INVALID_ERROR_CODE"; };
    RETURN {
        field: $clean_field,
        code: $clean_code,
        message: IF $message IS NONE { NONE } ELSE { string::trim($message) },
        details: IF $details IS NONE { {} } ELSE { $details }
    };
}
COMMENT "Construit une erreur de validation normalisée."
PERMISSIONS FULL;
