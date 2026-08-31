-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_datetime
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_datetime(
    $value: datetime,
    $precision: duration
) -> datetime {
    IF $precision <= 0s {
        THROW "SANITIZE_INVALID_DATETIME_PRECISION";
    };
    RETURN time::floor($value, $precision);
}
COMMENT "Tronque un datetime à une précision donnée."
PERMISSIONS FULL;
