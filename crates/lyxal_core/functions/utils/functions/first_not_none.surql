-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/first_not_none.surql
-- Fonction : fn::utils_first_not_none
--
-- Retourne la première valeur différente de NONE.
--
-- Paramètres
--   $values : array<any>
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_first_not_none(
    $values: array<any>
) -> any {
    LET $matches = array::filter(
        $values,
        |$value|$value IS NOT NONE
    );

    RETURN IF array::len($matches)=0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "Retourne la première valeur différente de NONE."
PERMISSIONS FULL;
