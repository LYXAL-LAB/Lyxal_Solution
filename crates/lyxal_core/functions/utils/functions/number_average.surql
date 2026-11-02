-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_average.surql
-- Fonction : fn::utils_number_average
--
-- Calcule la moyenne d'un tableau de nombres.
--
-- Paramètres
--   $values : array<number>
--
-- Valeur renvoyée : option<number> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
