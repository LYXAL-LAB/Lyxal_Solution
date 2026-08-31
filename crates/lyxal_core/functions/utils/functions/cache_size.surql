-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_size
-- Version  : 1.0.0
-- Statut   : Stable
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
