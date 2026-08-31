-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_string
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_string(
    $value: string,
    $algorithm: string
) -> string {
    LET $algo = string::lowercase(string::trim($algorithm));

    RETURN IF $algo = "sha256" {
        crypto::sha256($value)
    } ELSE IF $algo = "sha512" {
        crypto::sha512($value)
    } ELSE IF $algo = "blake3" {
        crypto::blake3($value)
    } ELSE {
        THROW "SECURITY_UNSUPPORTED_HASH_ALGORITHM"
    };
}
COMMENT "Calcule une empreinte déterministe selon l'algorithme choisi."
PERMISSIONS FULL;
