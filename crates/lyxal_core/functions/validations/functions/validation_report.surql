-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report(
    $subject: string,
    $field_results: array<object>
) -> object {
    LET $clean_subject = string::trim($subject);
    IF $clean_subject = "" { THROW "VALIDATION_INVALID_REPORT_SUBJECT"; };
    LET $errors = array::flatten(array::map($field_results, |$r| $r.errors));
    LET $warnings = array::flatten(array::map($field_results, |$r| $r.warnings));
    RETURN {
        subject: $clean_subject,
        valid: array::len($errors) = 0,
        fields: $field_results,
        errors: $errors,
        warnings: $warnings,
        error_count: array::len($errors),
        warning_count: array::len($warnings)
    };
}
COMMENT "Construit un rapport complet de validation."
PERMISSIONS FULL;
