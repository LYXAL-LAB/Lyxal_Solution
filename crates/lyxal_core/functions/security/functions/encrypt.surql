-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_encrypt
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_encrypt(
    $plaintext: bytes,
    $key_reference: string,
    $algorithm: string,
    $aad: option<bytes>
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !(["aes-256-gcm"] CONTAINS $algo) {
        THROW "SECURITY_UNSUPPORTED_CIPHER";
    };

    RETURN {
        operation: "encrypt",
        plaintext: $plaintext,
        key_reference: string::trim($key_reference),
        algorithm: $algo,
        aad: $aad,
        requires_native_crypto: true,
        authenticated_encryption_required: true
    };
}
COMMENT "Prépare un chiffrement authentifié AES-256-GCM pour le moteur Rust (lyxal_crypto)."
PERMISSIONS FULL;
