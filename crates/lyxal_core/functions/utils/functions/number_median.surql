-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_median.surql
-- Fonction : fn::utils_number_median
--
-- Calcule la médiane d'un tableau de nombres.
--
-- Paramètres
--   $values : array<number>
--
-- Valeur renvoyée : option<number> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
        ) / 2f
    };
}
COMMENT "Calcule la médiane d'un tableau de nombres."
PERMISSIONS FULL;
