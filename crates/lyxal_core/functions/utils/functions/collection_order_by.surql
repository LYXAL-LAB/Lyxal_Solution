-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_order_by
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_order_by(
    $value: array<object>,
    $criteria: array<object>
) -> array<object> {
    RETURN array::fold(
        array::reverse($criteria),
        $value,
        |$current,$criterion|
            fn::utils_collection_sort_by(
                $current,
                $criterion.key,
                IF $criterion.direction IS NONE {
                    "asc"
                } ELSE {
                    $criterion.direction
                }
            )
    );
}
COMMENT "Trie une collection selon plusieurs critères."
PERMISSIONS FULL;
