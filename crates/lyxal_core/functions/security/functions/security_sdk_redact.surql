-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_redact
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_redact(
    $value: any,
    $steps: array<object>
) -> object {
    LET $output = fn::security_redact_pipeline($value,$steps);

    RETURN {
        sdk:fn::security_sdk_version(),
        input_type:type::of($value),
        output:$output,
        changed:$value != $output
    };
}
COMMENT "Exécute un pipeline de redaction via le SDK."
PERMISSIONS FULL;
