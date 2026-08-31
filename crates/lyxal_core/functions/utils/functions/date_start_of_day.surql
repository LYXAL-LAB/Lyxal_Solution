-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_start_of_day
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_start_of_day(
    $value: datetime
) -> datetime {
    RETURN time::floor($value,1d);
}
COMMENT "Retourne le début de journée UTC."
PERMISSIONS FULL;
