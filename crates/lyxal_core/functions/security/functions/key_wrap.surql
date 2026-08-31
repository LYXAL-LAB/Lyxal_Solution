-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_key_wrap
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_key_wrap(
    $key_reference: string,
    $wrapping_key_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !array::contains(["aes-kw","aes-256-gcm"],$algo) {
        THROW "SECURITY_UNSUPPORTED_KEY_WRAP_ALGORITHM";
    };

    RETURN {
        operation: "key_wrap",
        key_reference: string::trim($key_reference),
        wrapping_key_reference: string::trim($wrapping_key_reference),
        algorithm: $algo,
        requires_native_crypto: true
    };
}
COMMENT "Prépare l'enveloppement d'une clé."
PERMISSIONS FULL;
