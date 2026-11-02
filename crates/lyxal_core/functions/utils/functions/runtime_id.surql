-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_id.surql
-- Fonction : fn::utils_runtime_id
--
-- Génère un identifiant runtime préfixé.
--
-- Paramètres
--   $prefix : string
--   $length : int
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $length < 8 OR $length > 128
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_id(
    $prefix: string,
    $length: int
) -> string {
    IF $length < 8 OR $length > 128 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $clean_prefix = string::lowercase(string::trim($prefix));
    LET $id = rand::id($length);

    RETURN IF $clean_prefix = "" {
        $id
    } ELSE {
        string::concat($clean_prefix,"_",$id)
    };
}
COMMENT "Génère un identifiant runtime préfixé."
PERMISSIONS FULL;
