-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_step
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_step(
    $value: option<any>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE OR type::is_null($value) OR !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_SANITIZE_STEP");
    };
    IF !type::is_string($value.rule) OR string::trim($value.rule) = "" {
        THROW string::concat($clean_field, "_INVALID_SANITIZE_STEP");
    };
    LET $rule = string::lowercase(string::trim($value.rule));
    IF !array::contains([
        "trim","lowercase","uppercase","capitalize","title_case",
        "collapse_whitespace","remove_control_chars","normalize_unicode",
        "slug","safe_identifier","default"
    ], $rule) {
        THROW string::concat($clean_field, "_UNKNOWN_SANITIZE_RULE");
    };
    RETURN {
        rule: $rule,
        value: $value.value,
        options: IF $value.options IS NONE { {} } ELSE { $value.options }
    };
}
COMMENT "Valide et normalise une étape de sanitation."
PERMISSIONS FULL;
