-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_timestamp
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_timestamp(
    $value: datetime
) -> string {
    RETURN <string>time::unix($value);
}
COMMENT "Normalise un timestamp de signature."
PERMISSIONS FULL;
