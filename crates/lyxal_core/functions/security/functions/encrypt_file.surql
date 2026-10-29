-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_encrypt_file
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_encrypt_file(
    $file_reference: string,
    $key_reference: string,
    $algorithm: string,
    $output_reference: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !(["aes-256-gcm"] CONTAINS $algo) {
        THROW "SECURITY_UNSUPPORTED_CIPHER";
    };

    RETURN {
        operation: "encrypt_file",
        file_reference: string::trim($file_reference),
        output_reference: string::trim($output_reference),
        key_reference: string::trim($key_reference),
        algorithm: $algo,
        requires_native_crypto: true,
        streaming_required: true
    };
}
COMMENT "Prépare le chiffrement en flux AES-256-GCM d'un fichier par le moteur Rust (lyxal_crypto)."
PERMISSIONS FULL;
