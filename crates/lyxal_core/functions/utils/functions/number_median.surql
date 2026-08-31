-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_median
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_median(
    $values: array<number>
) -> option<number> {
    LET $count = array::len($values);

    IF $count = 0 {
        RETURN NONE;
    };

    LET $sorted = array::sort::asc($values);
    LET $middle = math::floor($count/2);

    RETURN IF $count % 2 = 1 {
        $sorted[type::int($middle)]
    } ELSE {
        (
            $sorted[type::int($middle)-1]
            + $sorted[type::int($middle)]
        ) / 2
    };
}
COMMENT "Calcule la médiane d'un tableau de nombres."
PERMISSIONS FULL;
