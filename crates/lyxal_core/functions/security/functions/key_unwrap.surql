-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_key_unwrap
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_key_unwrap(
    $wrapped_key: bytes,
    $wrapping_key_reference: string,
    $algorithm: string,
    $output_reference: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !array::contains(["aes-kw","aes-256-gcm"],$algo) {
        THROW "SECURITY_UNSUPPORTED_KEY_WRAP_ALGORITHM";
    };

    RETURN {
        operation: "key_unwrap",
        wrapped_key: $wrapped_key,
        wrapping_key_reference: string::trim($wrapping_key_reference),
        algorithm: $algo,
        output_reference: string::trim($output_reference),
        requires_native_crypto: true,
        export_plaintext_key: false
    };
}
COMMENT "Prépare le désenveloppement natif d'une clé."
PERMISSIONS FULL;
