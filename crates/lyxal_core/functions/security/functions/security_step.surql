-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_step
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_step(
    $value: option<any>,
    $field: string
) -> object {
    LET $f = string::trim($field);
    IF $value IS NONE OR type::is_null($value) OR !type::is_object($value) {
        THROW string::concat($f,"_INVALID_SECURITY_STEP");
    };

    LET $rule = string::lowercase(string::trim($value.rule));

    IF !array::contains([
        "detect_payload",
        "detect_file",
        "redact_email",
        "redact_phone",
        "redact_card",
        "redact_secret",
        "redact_log",
        "redact_object",
        "permission_check"
    ],$rule) {
        THROW string::concat($f,"_UNKNOWN_SECURITY_RULE");
    };

    RETURN {
        rule:$rule,
        options:IF $value.options IS NONE{{}}ELSE{$value.options}
    };
}
COMMENT "Valide et normalise une étape de pipeline Security."
PERMISSIONS FULL;
