-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_merge(
    $left: object,
    $right: object,
    $subject: string
) -> object {
    LET $errors = array::concat($left.errors, $right.errors);
    LET $warnings = array::concat($left.warnings, $right.warnings);
    LET $fields = array::concat(
        IF $left.fields IS NONE { [] } ELSE { $left.fields },
        IF $right.fields IS NONE { [] } ELSE { $right.fields }
    );
    RETURN {
        subject: string::trim($subject),
        valid: array::len($errors) = 0,
        fields: $fields,
        errors: $errors,
        warnings: $warnings,
        error_count: array::len($errors),
        warning_count: array::len($warnings)
    };
}
COMMENT "Fusionne deux rapports de validation."
PERMISSIONS FULL;
