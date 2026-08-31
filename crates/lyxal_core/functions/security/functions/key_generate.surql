-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_key_generate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_key_generate(
    $algorithm: string,
    $key_reference: string,
    $usage: array<string>
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !array::contains(
        ["aes-256-gcm","chacha20-poly1305","xchacha20-poly1305","ed25519","es256","es384"],
        $algo
    ) {
        THROW "SECURITY_UNSUPPORTED_KEY_ALGORITHM";
    };

    RETURN {
        operation: "key_generate",
        algorithm: $algo,
        key_reference: string::trim($key_reference),
        usage: array::distinct($usage),
        requires_native_crypto: true,
        export_private_key: false
    };
}
COMMENT "Prépare la génération native d'une clé."
PERMISSIONS FULL;
