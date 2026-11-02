-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/is_blank.surql
-- Fonction : fn::utils_is_blank
--
-- Indique si une valeur textuelle est blanche.
--
-- Paramètres
--   $value : any
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_is_blank(
    $value: any
) -> bool {
    RETURN $value IS NONE
        OR type::is_null($value)
        OR (
            type::is_string($value)
            AND string::trim($value)=""
        );
}
COMMENT "Indique si une valeur textuelle est blanche."
PERMISSIONS FULL;
