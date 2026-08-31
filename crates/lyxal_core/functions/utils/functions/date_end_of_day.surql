-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_end_of_day
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_end_of_day(
    $value: datetime
) -> datetime {
    RETURN time::floor($value,1d)+1d-1ns;
}
COMMENT "Retourne la fin de journée UTC."
PERMISSIONS FULL;
