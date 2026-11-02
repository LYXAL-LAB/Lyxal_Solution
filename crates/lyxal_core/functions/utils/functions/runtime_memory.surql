-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_memory.surql
-- Fonction : fn::utils_runtime_memory
--
-- Estime la taille mémoire d'une valeur via son JSON.
--
-- Paramètres
--   $value : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_memory(
    $value: any
) -> object {
    LET $json = encoding::json::encode($value);

    RETURN {
        estimated_bytes:string::len($json),
        measurement:"json_character_length",
        value_type:type::of($value)
    };
}
COMMENT "Estime la taille mémoire d'une valeur via son JSON."
PERMISSIONS FULL;
