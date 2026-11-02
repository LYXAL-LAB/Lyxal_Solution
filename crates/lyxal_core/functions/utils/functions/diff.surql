-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/diff.surql
-- Fonction : fn::utils_diff
--
-- Produit un diff générique entre deux valeurs.
--
-- Paramètres
--   $left  : any
--   $right : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_diff(
    $left: any,
    $right: any
) -> object {
    RETURN {
        equal:$left == $right,
        left:$left,
        right:$right,
        left_type:type::of($left),
        right_type:type::of($right)
    };
}
COMMENT "Produit un diff générique entre deux valeurs."
PERMISSIONS FULL;
