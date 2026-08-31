-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_sort_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_sort_by(
    $value: array<object>,
    $key: string,
    $direction: string
) -> array<object> {
    LET $clean_direction = string::lowercase(
        string::trim($direction)
    );

    RETURN IF $clean_direction = "asc" {
        array::sort::asc($value,$key)
    } ELSE IF $clean_direction = "desc" {
        array::sort::desc($value,$key)
    } ELSE {
        THROW "UTILS_INVALID_SORT_DIRECTION"
    };
}
COMMENT "Trie une collection d'objets selon une clé."
PERMISSIONS FULL;
