-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_calendar
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_calendar(
    $value: datetime,
    $granularity: string
) -> datetime {
    LET $g = string::lowercase(string::trim($granularity));
    RETURN IF $g IN ["year","month","day","hour","minute","second"] {
        time::group($value, $g)
    } ELSE {
        THROW "SANITIZE_INVALID_CALENDAR_GRANULARITY"
    };
}
COMMENT "Regroupe un datetime selon une granularité calendaire."
PERMISSIONS FULL;
