-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_verify
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_verify(
    $hash: string,
    $value: string,
    $algorithm: string
) -> bool {
    LET $algo = string::lowercase(string::trim($algorithm));

    RETURN IF $algo = "argon2" {
        THROW "SECURITY_NATIVE_PASSWORD_VERIFY_REQUIRED"
    } ELSE IF $algo = "sha256" {
        $hash == crypto::sha256($value)
    } ELSE IF $algo = "blake3" {
        $hash == crypto::blake3($value)
    } ELSE {
        THROW "SECURITY_UNSUPPORTED_HASH_ALGORITHM"
    };
}
COMMENT "
Vérifie une empreinte non secrète (SHA-256 ou BLAKE3). La vérification de mots
de passe Argon2id est exclusivement déléguée à lyxal_crypto::password::verify_password.
"
PERMISSIONS FULL;
