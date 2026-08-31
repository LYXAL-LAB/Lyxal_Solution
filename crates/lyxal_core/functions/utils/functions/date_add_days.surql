-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_add_days
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_add_days(
    $value: datetime,
    $days: int
) -> datetime {
    RETURN $value + duration::from_days($days);
}
COMMENT "Ajoute un nombre entier de jours à une date."
PERMISSIONS FULL;
