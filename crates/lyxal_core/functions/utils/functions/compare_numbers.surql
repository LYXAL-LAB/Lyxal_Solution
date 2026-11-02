-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/compare_numbers.surql
-- Fonction : fn::utils_compare_numbers
--
-- Compare deux nombres avec une tolérance.
--
-- Paramètres
--   $left      : number
--   $right     : number
--   $tolerance : number
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $tolerance < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_compare_numbers(
    $left: number,
    $right: number,
    $tolerance: number
) -> int {
    IF $tolerance < 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN IF math::abs($left-$right) <= $tolerance {
        0
    } ELSE IF $left < $right {
        -1
    } ELSE {
        1
    };
}
COMMENT "Compare deux nombres avec une tolérance."
PERMISSIONS FULL;
