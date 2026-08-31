-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_report(
    $subject: string,
    $input: any,
    $output: any,
    $fields: array<string>
) -> object {
    RETURN {
        subject: string::trim($subject),
        changed: $input != $output,
        redacted_fields: array::distinct($fields),
        input_type: type::of($input),
        output_type: type::of($output),
        generated_at: time::now()
    };
}
COMMENT "Produit un rapport sans réexposer les valeurs sensibles."
PERMISSIONS FULL;
