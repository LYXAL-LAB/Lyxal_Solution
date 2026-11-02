-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_string.surql
-- Fonction : fn::security_hash_string
--
-- Calcule une empreinte déterministe selon l'algorithme choisi.
--
-- Paramètres
--   $value     : string
--   $algorithm : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : $algo = "sha256" { crypto::sha256($value) } ELSE IF $algo = "blake3" { crypto::blake3($value) } ELSE
--   CORE_UNSUPPORTED_OPTION : option inconnue
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_string(
    $value: string,
    $algorithm: string
) -> string {
    LET $algo = string::lowercase(string::trim($algorithm));

    RETURN IF $algo = "sha256" {
        crypto::sha256($value)
    } ELSE IF $algo = "blake3" {
        crypto::blake3($value)
    } ELSE {
        THROW "CORE_UNSUPPORTED_OPTION"
    };
}
COMMENT "Calcule une empreinte déterministe selon l'algorithme choisi."
PERMISSIONS FULL;
