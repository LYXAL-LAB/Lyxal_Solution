-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_info(
    $hash: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    RETURN {
        algorithm: $algo,
        hash: $hash,
        length: string::len($hash),
        password_suitable: $algo IN ["argon2","bcrypt","pbkdf2","scrypt"],
        deterministic: !($algo IN ["argon2","bcrypt","pbkdf2","scrypt"])
    };
}
COMMENT "Retourne les métadonnées d'une empreinte."
PERMISSIONS FULL;
