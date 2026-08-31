-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_add_warning
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_add_warning(
    $report: object,
    $warning: object
) -> object {
    LET $warnings = array::append($report.warnings, $warning);
    RETURN object::extend($report, {
        warnings: $warnings,
        warning_count: array::len($warnings)
    });
}
COMMENT "Ajoute un avertissement à un rapport."
PERMISSIONS FULL;
