-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_order_by.surql
-- Fonction : fn::utils_collection_order_by
--
-- Trie une collection selon plusieurs critères.
--
-- Paramètres
--   $value    : array<object>
--   $criteria : array<object>
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
