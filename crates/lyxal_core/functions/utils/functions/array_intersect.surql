-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_intersect.surql
-- Fonction : fn::utils_array_intersect
--
-- Retourne l'intersection de deux tableaux.
--
-- Paramètres
--   $left  : array<any>
--   $right : array<any>
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_intersect(
    $left: array<any>,
    $right: array<any>
) -> array<any> {
    RETURN array::distinct(
        array::filter(
            $left,
            |$item| (($right) CONTAINS ($item))
        )
    );
}
COMMENT "Retourne l'intersection de deux tableaux."
PERMISSIONS FULL;
