-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_memory
-- Version  : 1.0.0
-- Statut   : Stable
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
