-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_nonce
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_nonce(
    $length: int
) -> string {
    IF $length < 16 OR $length > 128 {
        THROW "SECURITY_INVALID_NONCE_LENGTH";
    };
    RETURN rand::id($length);
}
COMMENT "Génère un nonce alphanumérique avec rand::id."
PERMISSIONS FULL;
