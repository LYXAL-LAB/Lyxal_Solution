-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/is_empty.surql
-- Fonction : fn::utils_is_empty
--
-- Indique si une valeur est vide.
--
-- Paramètres
--   $value : any
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_is_empty(
    $value: any
) -> bool {
    RETURN $value IS NONE
        OR type::is_null($value)
        OR (type::is_string($value) AND string::len($value)=0)
        OR (type::is_array($value) AND array::len($value)=0)
        OR (type::is_object($value) AND object::len($value)=0);
}
COMMENT "Indique si une valeur est vide."
PERMISSIONS FULL;
