-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/compare_arrays.surql
-- Fonction : fn::utils_compare_arrays
--
-- Compare deux tableaux avec ou sans prise en compte de l'ordre.
--
-- Paramètres
--   $left         : array<any>
--   $right        : array<any>
--   $ignore_order : bool
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_compare_arrays(
    $left: array<any>,
    $right: array<any>,
    $ignore_order: bool
) -> object {
    LET $normalized_left = IF $ignore_order {
        array::sort::asc($left)
    } ELSE {
        $left
    };

    LET $normalized_right = IF $ignore_order {
        array::sort::asc($right)
    } ELSE {
        $right
    };

    RETURN {
        equal:$normalized_left = $normalized_right,
        left_only:fn::utils_array_difference($left,$right),
        right_only:fn::utils_array_difference($right,$left)
    };
}
COMMENT "Compare deux tableaux avec ou sans prise en compte de l'ordre."
PERMISSIONS FULL;
