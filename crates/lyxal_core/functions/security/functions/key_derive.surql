-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_key_derive
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_key_derive(
    $master_key_reference: string,
    $context: string,
    $salt: bytes,
    $algorithm: string,
    $output_reference: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !array::contains(["hkdf-sha256","hkdf-sha512"],$algo) {
        THROW "SECURITY_UNSUPPORTED_KDF";
    };

    RETURN {
        operation: "key_derive",
        master_key_reference: string::trim($master_key_reference),
        context: string::trim($context),
        salt: $salt,
        algorithm: $algo,
        output_reference: string::trim($output_reference),
        requires_native_crypto: true
    };
}
COMMENT "Prépare une dérivation de clé HKDF."
PERMISSIONS FULL;
