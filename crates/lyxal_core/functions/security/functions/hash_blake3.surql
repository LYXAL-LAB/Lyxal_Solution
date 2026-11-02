-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_blake3.surql
-- Fonction : fn::security_hash_blake3
--
-- Calcule l'empreinte BLAKE3 native d'une chaîne.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_blake3(
    $value: string
) -> string {
    RETURN crypto::blake3($value);
}
COMMENT "Calcule l'empreinte BLAKE3 native d'une chaîne."
PERMISSIONS FULL;
