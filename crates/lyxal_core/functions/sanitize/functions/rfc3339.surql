-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_rfc3339
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_rfc3339(
    $value: datetime
) -> string {
    RETURN time::format(
        $value,
        "%Y-%m-%dT%H:%M:%S%.fZ"
    );
}
COMMENT "Formate un datetime UTC dans une représentation compatible RFC 3339."
PERMISSIONS FULL;
