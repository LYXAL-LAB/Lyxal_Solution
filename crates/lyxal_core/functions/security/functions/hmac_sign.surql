-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_sign
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_sign(
    $canonical: string,
    $secret_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    IF !array::contains(["hmac-sha256","hmac-sha512"],$algo) {
        THROW "SECURITY_UNSUPPORTED_HMAC_ALGORITHM";
    };

    RETURN {
        operation: "hmac_sign",
        algorithm: $algo,
        canonical: $canonical,
        secret_reference: string::trim($secret_reference),
        requires_native_crypto: true
    };
}
COMMENT "
Prépare une demande de signature HMAC pour le moteur Rust. Aucun faux HMAC
n'est calculé en SurrealQL.
"
PERMISSIONS FULL;
