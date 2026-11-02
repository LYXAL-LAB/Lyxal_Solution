-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_size.surql
-- Fonction : fn::utils_cache_size
--
-- Estime la taille d'un cache via sa représentation JSON.
--
-- Paramètres
--   $entries : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_size(
    $entries: array<object>
) -> object {
    LET $json = encoding::json::encode($entries);

    RETURN {
        entry_count:array::len($entries),
        estimated_bytes:string::len($json),
        measurement:"json_character_length"
    };
}
COMMENT "Estime la taille d'un cache via sa représentation JSON."
PERMISSIONS FULL;
