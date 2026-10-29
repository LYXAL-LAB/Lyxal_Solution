-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_cipher_info
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_cipher_info() -> object {
    RETURN {
        native_surrealql: false,
        authenticated_ciphers: [
            "aes-256-gcm"
        ],
        key_derivation: ["hkdf-sha256"],
        key_wrap: ["aes-256-gcm"],
        engine: "lyxal_crypto",
        plaintext_key_export_forbidden: true
    };
}
COMMENT "Documente le contrat de chiffrement du moteur Security (lyxal_crypto)."
PERMISSIONS FULL;
