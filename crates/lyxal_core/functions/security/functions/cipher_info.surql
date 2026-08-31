-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_cipher_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_cipher_info() -> object {
    RETURN {
        native_surrealql: false,
        authenticated_ciphers: [
            "aes-256-gcm",
            "chacha20-poly1305",
            "xchacha20-poly1305"
        ],
        key_derivation: ["hkdf-sha256","hkdf-sha512"],
        key_wrap: ["aes-kw","aes-256-gcm"],
        engine: "lyxal_security_native_rust",
        plaintext_key_export_forbidden: true
    };
}
COMMENT "Documente le contrat de chiffrement du moteur Security."
PERMISSIONS FULL;
