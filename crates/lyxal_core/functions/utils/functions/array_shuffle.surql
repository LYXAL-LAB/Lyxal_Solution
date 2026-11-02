-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_shuffle.surql
-- Fonction : fn::utils_array_shuffle
--
-- Mélange aléatoirement les éléments d'un tableau.
--
-- Paramètres
--   $value : array<any>
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_shuffle(
    $value: array<any>
) -> array<any> {
    RETURN array::shuffle($value);
}
COMMENT "Mélange aléatoirement les éléments d'un tableau."
PERMISSIONS FULL;
