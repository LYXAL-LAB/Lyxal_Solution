-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_verify(
    $canonical: string,
    $signature: string,
    $secret_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    IF !array::contains(["hmac-sha256","hmac-sha512"],$algo) {
        THROW "SECURITY_UNSUPPORTED_HMAC_ALGORITHM";
    };

    RETURN {
        operation: "hmac_verify",
        algorithm: $algo,
        canonical: $canonical,
        signature: string::trim($signature),
        secret_reference: string::trim($secret_reference),
        requires_native_crypto: true,
        constant_time_required: true
    };
}
COMMENT "Prépare une vérification HMAC constante en temps pour le moteur Rust."
PERMISSIONS FULL;
