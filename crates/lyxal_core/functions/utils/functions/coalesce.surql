-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/coalesce.surql
-- Fonction : fn::utils_coalesce
--
-- Retourne la première valeur ni NONE ni NULL.
--
-- Paramètres
--   $values : array<any>
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_coalesce(
    $values: array<any>
) -> any {
    LET $matches = array::filter(
        $values,
        |$value|$value IS NOT NONE AND !type::is_null($value)
    );

    RETURN IF array::len($matches)=0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "Retourne la première valeur ni NONE ni NULL."
PERMISSIONS FULL;
