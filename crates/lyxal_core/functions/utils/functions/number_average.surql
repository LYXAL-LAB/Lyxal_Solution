-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_average
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_average(
    $values: array<number>
) -> option<number> {
    IF array::len($values) = 0 {
        RETURN NONE;
    };

    RETURN array::fold(
        $values,
        0,
        |$sum,$value| $sum+$value
    ) / array::len($values);
}
COMMENT "Calcule la moyenne d'un tableau de nombres."
PERMISSIONS FULL;
