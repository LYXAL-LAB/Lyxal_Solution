-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_sign
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_sign(
    $canonical: string,
    $key_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));

    IF !array::contains(
        ["ed25519","es256","es384","rs256","ps256"],
        $algo
    ) {
        THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM";
    };

    RETURN {
        operation: "asymmetric_sign",
        canonical: $canonical,
        key_reference: string::trim($key_reference),
        algorithm: $algo,
        requires_native_crypto: true
    };
}
COMMENT "Prépare une signature asymétrique pour le moteur Rust."
PERMISSIONS FULL;
