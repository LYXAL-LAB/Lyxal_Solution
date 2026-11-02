-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/secret_info.surql
-- Fonction : fn::security_secret_info
--
-- Construit les métadonnées publiques d'un secret sans sa valeur.
--
-- Paramètres
--   $reference  : string
--   $created_at : datetime
--   $rotated_at : option<datetime>
--   $status     : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_secret_info(
    $reference: string,
    $created_at: datetime,
    $rotated_at: option<datetime>,
    $status: string
) -> object {
    RETURN {
        reference: string::trim($reference),
        created_at: $created_at,
        rotated_at: $rotated_at,
        status: string::lowercase(string::trim($status)),
        contains_plaintext: false
    };
}
COMMENT "Construit les métadonnées publiques d'un secret sans sa valeur."
PERMISSIONS FULL;
