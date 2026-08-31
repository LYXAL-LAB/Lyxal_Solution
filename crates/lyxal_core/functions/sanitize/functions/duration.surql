-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_duration
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_duration(
    $value: duration,
    $precision: duration
) -> duration {
    IF $precision <= 0s {
        THROW "SANITIZE_INVALID_DURATION_PRECISION";
    };
    LET $nanos = duration::nanos($value);
    LET $step = duration::nanos($precision);
    LET $rounded = math::floor($nanos / $step) * $step;
    RETURN duration::from_nanos(type::int($rounded));
}
COMMENT "Tronque une durée à une précision donnée."
PERMISSIONS FULL;
