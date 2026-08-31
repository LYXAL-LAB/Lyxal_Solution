-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_sum
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_sum(
    $values: array<number>
) -> number {
    RETURN array::fold(
        $values,
        0,
        |$sum,$value| $sum+$value
    );
}
COMMENT "Calcule la somme d'un tableau de nombres."
PERMISSIONS FULL;
