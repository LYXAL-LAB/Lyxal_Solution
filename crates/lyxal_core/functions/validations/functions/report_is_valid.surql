-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_is_valid
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_is_valid(
    $report: object
) -> bool {
    RETURN array::len($report.errors) = 0;
}
COMMENT "Retourne true lorsqu'un rapport ne contient aucune erreur."
PERMISSIONS FULL;
