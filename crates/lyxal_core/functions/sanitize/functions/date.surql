-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_date
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_date(
    $value: datetime
) -> datetime {
    RETURN time::floor($value, 1d);
}
COMMENT "Ramène un datetime au début de sa journée UTC."
PERMISSIONS FULL;
