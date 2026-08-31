-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_warning
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_warning(
    $field: string,
    $code: string,
    $message: option<string>,
    $details: option<object>
) -> object {
    LET $clean_field = string::trim($field);
    LET $clean_code = string::uppercase(string::trim($code));
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $clean_code = "" { THROW "VALIDATION_INVALID_WARNING_CODE"; };
    RETURN {
        field: $clean_field,
        code: $clean_code,
        message: IF $message IS NONE { NONE } ELSE { string::trim($message) },
        details: IF $details IS NONE { {} } ELSE { $details }
    };
}
COMMENT "Construit un avertissement de validation normalisé."
PERMISSIONS FULL;
