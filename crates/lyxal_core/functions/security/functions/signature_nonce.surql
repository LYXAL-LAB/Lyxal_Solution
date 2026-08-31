-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_nonce
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_nonce(
    $length: int
) -> string {
    IF $length < 16 OR $length > 128 {
        THROW "SECURITY_INVALID_SIGNATURE_NONCE_LENGTH";
    };
    RETURN rand::id($length);
}
COMMENT "Génère un nonce de signature."
PERMISSIONS FULL;
