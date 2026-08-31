-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_is_weekend
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_is_weekend(
    $value: datetime
) -> bool {
    LET $weekday = time::wday($value);

    RETURN $weekday = 6 OR $weekday = 7;
}
COMMENT "Indique si une date tombe un samedi ou un dimanche."
PERMISSIONS FULL;
