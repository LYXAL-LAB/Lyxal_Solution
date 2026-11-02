-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_sha512.surql
-- Fonction : fn::security_hash_sha512
--
-- Calcule l'empreinte SHA-512 native d'une chaîne.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_sha512(
    $value: string
) -> string {
    RETURN crypto::sha512($value);
}
COMMENT "Calcule l'empreinte SHA-512 native d'une chaîne."
PERMISSIONS FULL;
