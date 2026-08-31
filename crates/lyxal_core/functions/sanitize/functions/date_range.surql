-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_date_range
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_date_range(
    $start: datetime,
    $end: datetime,
    $swap_if_reversed: bool
) -> object {
    IF $start <= $end {
        RETURN { start: $start, end: $end };
    };
    IF $swap_if_reversed {
        RETURN { start: $end, end: $start };
    };
    THROW "SANITIZE_REVERSED_DATE_RANGE";
}
COMMENT "Normalise une plage de dates et peut inverser les bornes."
PERMISSIONS FULL;
