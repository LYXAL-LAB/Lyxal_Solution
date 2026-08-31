-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_verify(
    $hash: string,
    $value: string,
    $algorithm: string
) -> bool {
    LET $algo = string::lowercase(string::trim($algorithm));

    RETURN IF $algo = "argon2" {
        crypto::argon2::compare($hash, $value)
    } ELSE IF $algo = "sha256" {
        $hash = crypto::sha256($value)
    } ELSE IF $algo = "sha512" {
        $hash = crypto::sha512($value)
    } ELSE IF $algo = "blake3" {
        $hash = crypto::blake3($value)
    } ELSE {
        THROW "SECURITY_UNSUPPORTED_HASH_ALGORITHM"
    };
}
COMMENT "
Vérifie un hash. Argon2 utilise le comparateur natif ; les empreintes simples
utilisent une égalité ordinaire et ne doivent pas protéger des mots de passe.
"
PERMISSIONS FULL;
