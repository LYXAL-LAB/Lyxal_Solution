-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_error_count
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_error_count(
    $report: object
) -> int {
    RETURN array::len($report.errors);
}
COMMENT "Retourne le nombre d'erreurs d'un rapport."
PERMISSIONS FULL;
