-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_sha256.surql
-- Fonction : fn::security_hash_sha256
--
-- Calcule l'empreinte SHA-256 native d'une chaîne.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_sha256(
    $value: string
) -> string {
    RETURN crypto::sha256($value);
}
COMMENT "Calcule l'empreinte SHA-256 native d'une chaîne."
PERMISSIONS FULL;
