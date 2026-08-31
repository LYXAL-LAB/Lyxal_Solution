-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_nonce
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_nonce(
    $length: int
) -> string {
    IF $length < 16 OR $length > 128 {
        THROW "SECURITY_INVALID_TOKEN_NONCE_LENGTH";
    };
    RETURN rand::id($length);
}
COMMENT "Génère un nonce de token."
PERMISSIONS FULL;
