-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_add_error
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_add_error(
    $report: object,
    $error: object
) -> object {
    LET $errors = array::append($report.errors, $error);
    RETURN object::extend($report, {
        valid: false,
        errors: $errors,
        error_count: array::len($errors)
    });
}
COMMENT "Ajoute une erreur à un rapport."
PERMISSIONS FULL;
