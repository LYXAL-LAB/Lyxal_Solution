-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_info.surql
-- Fonction : fn::security_hash_info
--
-- Retourne les métadonnées d'une empreinte.
--
-- Paramètres
--   $hash      : string
--   $algorithm : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
