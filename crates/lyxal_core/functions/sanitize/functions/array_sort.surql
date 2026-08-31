-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_sort
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_sort(
    $value: array<any>,
    $direction: string
) -> array<any> {
    LET $d = string::lowercase(string::trim($direction));
    RETURN IF $d = "asc" {
        array::sort::asc($value)
    } ELSE IF $d = "desc" {
        array::sort::desc($value)
    } ELSE {
        THROW "SANITIZE_INVALID_SORT_DIRECTION"
    };
}
COMMENT "Trie un tableau en ordre ascendant ou descendant."
PERMISSIONS FULL;
