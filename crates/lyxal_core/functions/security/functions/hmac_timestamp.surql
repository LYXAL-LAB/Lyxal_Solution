-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_timestamp
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_timestamp(
    $value: datetime
) -> string {
    RETURN <string>time::unix($value);
}
COMMENT "Transforme un datetime en timestamp Unix textuel pour une signature."
PERMISSIONS FULL;
