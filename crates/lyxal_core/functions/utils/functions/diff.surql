-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_diff
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_diff(
    $left: any,
    $right: any
) -> object {
    RETURN {
        equal:fn::utils_deep_equal($left,$right),
        left:$left,
        right:$right,
        left_type:type::of($left),
        right_type:type::of($right)
    };
}
COMMENT "Produit un diff générique entre deux valeurs."
PERMISSIONS FULL;
