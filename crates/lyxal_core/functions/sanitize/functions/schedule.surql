-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schedule
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schedule(
    $start_at: datetime,
    $duration: duration,
    $round_to: duration
) -> object {
    IF $duration < 0s OR $round_to <= 0s {
        THROW "SANITIZE_INVALID_SCHEDULE_VALUES";
    };
    LET $start = time::floor($start_at, $round_to);
    RETURN {
        start_at: $start,
        end_at: $start + $duration,
        duration: $duration
    };
}
COMMENT "Normalise un créneau avec début arrondi et fin calculée."
PERMISSIONS FULL;
