-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_start_of_month
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_start_of_month(
    $value: datetime
) -> datetime {
    RETURN time::group($value,"month");
}
COMMENT "Retourne le début du mois UTC."
PERMISSIONS FULL;
