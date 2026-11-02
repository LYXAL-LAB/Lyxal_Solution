-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_verify.surql
-- Fonction : fn::security_hash_verify
--
-- Vérifie qu'une empreinte SHA-256 ou BLAKE3 correspond à une valeur
-- (comparaison simple, non constante en temps : pour un secret, utiliser
-- lyxal_crypto). L'empreinte attendue est comparée sans tenir compte de la
-- casse.
--
-- Paramètres
--   $hash      : string
--   $value     : string
--   $algorithm : string
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : $algo NOT IN ["sha256", "blake3"]
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_verify(
    $hash: string,
    $value: string,
    $algorithm: string
) -> bool {
    LET $algo = string::lowercase(string::trim($algorithm));
    IF $algo NOT IN ["sha256", "blake3"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    RETURN string::lowercase($hash) == fn::security_hash_string($value, $algo);
}
COMMENT "Vérifie qu'une empreinte SHA-256 ou BLAKE3 correspond à une valeur (comparaison simple, non constante en temps : pour un secret, utiliser lyxal_crypto). L'empreinte attendue est comparée sans tenir compte de la casse."
PERMISSIONS FULL;
