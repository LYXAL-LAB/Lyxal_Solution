-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_timestamp
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_timestamp(
    $value: datetime,
    $unit: string
) -> int {
    LET $clean_unit = string::lowercase(string::trim($unit));
    RETURN IF $clean_unit = "seconds" {
        time::unix($value)
    } ELSE IF $clean_unit = "milliseconds" {
        time::millis($value)
    } ELSE IF $clean_unit = "microseconds" {
        time::micros($value)
    } ELSE IF $clean_unit = "nanoseconds" {
        time::nano($value)
    } ELSE {
        THROW "SANITIZE_INVALID_TIMESTAMP_UNIT"
    };
}
COMMENT "Convertit un datetime en timestamp selon l'unité demandée."
PERMISSIONS FULL;
