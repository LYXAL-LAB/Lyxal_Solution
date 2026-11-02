-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_difference.surql
-- Fonction : fn::utils_array_difference
--
-- Retourne les éléments du premier tableau absents du second.
--
-- Paramètres
--   $left  : array<any>
--   $right : array<any>
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_difference(
    $left: array<any>,
    $right: array<any>
) -> array<any> {
    RETURN array::filter(
        $left,
        |$item| !(($right) CONTAINS ($item))
    );
}
COMMENT "Retourne les éléments du premier tableau absents du second."
PERMISSIONS FULL;
