-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_sign
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_sign(
    $claims: object,
    $key_reference: string,
    $algorithm: string,
    $token_type: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    IF !array::contains(
        ["ed25519","es256","es384","rs256","ps256"],
        $algo
    ) {
        THROW "SECURITY_UNSUPPORTED_TOKEN_SIGNATURE_ALGORITHM";
    };

    RETURN {
        operation: "token_sign",
        token_type: string::lowercase(string::trim($token_type)),
        algorithm: $algo,
        claims: $claims,
        key_reference: string::trim($key_reference),
        requires_native_crypto: true
    };
}
COMMENT "Prépare la signature d'un token structuré par le moteur Rust."
PERMISSIONS FULL;
