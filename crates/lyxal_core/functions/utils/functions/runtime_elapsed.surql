-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_elapsed
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_elapsed(
    $started_at: datetime,
    $now: datetime
) -> object {
    IF $now < $started_at {
        THROW "UTILS_INVALID_RUNTIME_TIME_RANGE";
    };

    LET $duration = $now-$started_at;

    RETURN {
        duration:$duration,
        seconds:duration::secs($duration),
        milliseconds:duration::millis($duration),
        microseconds:duration::micros($duration)
    };
}
COMMENT "Retourne la durée écoulée dans plusieurs unités."
PERMISSIONS FULL;
