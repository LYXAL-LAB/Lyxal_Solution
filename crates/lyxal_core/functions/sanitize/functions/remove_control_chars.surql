-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_control_chars.surql
-- Fonction : fn::sanitize_remove_control_chars
--
-- Retire les caractères de contrôle ASCII (U+0000 à U+001F et U+007F) ;
-- tabulation, retour à la ligne et retour chariot sont conservés si demandé.
--
-- Paramètres
--   $value           : any — valeur à nettoyer (chaîne, ou NONE)
--   $preserve_layout : bool — true pour conserver \t, \n et \r
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans caractère de contrôle
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $text = fn::sanitize_remove_control_chars($params.text, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_control_chars(
    $value: any,
    $preserve_layout: bool
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $pattern = IF $preserve_layout { "[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]" } ELSE { "[\\x00-\\x1F\\x7F]" };
    RETURN string::replace($value, <regex>$pattern, "");
}
COMMENT "Retire les caractères de contrôle ASCII (U+0000 à U+001F et U+007F). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
