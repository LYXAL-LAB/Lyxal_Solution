-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_arrays
-- Version  : 1.0.0
-- Statut   : Stable
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
