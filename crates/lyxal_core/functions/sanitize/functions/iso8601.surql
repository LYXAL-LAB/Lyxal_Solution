-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_iso8601
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_iso8601(
    $value: datetime
) -> string {
    RETURN time::format(
        $value,
        "%Y-%m-%dT%H:%M:%S%.fZ"
    );
}
COMMENT "Formate un datetime en représentation ISO 8601 UTC."
PERMISSIONS FULL;
