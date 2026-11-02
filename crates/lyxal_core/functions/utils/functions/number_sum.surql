-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_sum.surql
-- Fonction : fn::utils_number_sum
--
-- Calcule la somme d'un tableau de nombres.
--
-- Paramètres
--   $values : array<number>
--
-- Valeur renvoyée : number (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
