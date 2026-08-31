-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_diff_days
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_diff_days(
    $start: datetime,
    $end: datetime
) -> decimal {
    RETURN type::decimal(
        duration::secs($end-$start)
    ) / 86400dec;
}
COMMENT "Calcule l'écart entre deux dates en jours décimaux."
PERMISSIONS FULL;
