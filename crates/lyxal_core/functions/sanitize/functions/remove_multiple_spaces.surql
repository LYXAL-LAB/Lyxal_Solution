-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_multiple_spaces.surql
-- Fonction : fn::sanitize_remove_multiple_spaces
--
-- Remplace les suites d'espaces (U+0020 uniquement) par une espace simple ;
-- tabulations et retours à la ligne sont conservés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans espaces multiples
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_remove_multiple_spaces($params.remove_multiple_spaces);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_multiple_spaces(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>" {2,}", " ");
}
COMMENT "Remplace les suites d'espaces (U+0020 uniquement) par une espace simple. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
