-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_newlines.surql
-- Fonction : fn::sanitize_remove_newlines
--
-- Remplace les retours à la ligne (\r\n, \n, \r) par une chaîne de
-- remplacement.
--
-- Paramètres
--   $value       : any — valeur à nettoyer (chaîne, ou NONE)
--   $replacement : string — texte de remplacement (ex. " " ou "")
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans retour à la ligne
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $line = fn::sanitize_remove_newlines($params.comment, " ");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_newlines(
    $value: any,
    $replacement: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"\\r\\n|\\n|\\r", $replacement);
}
COMMENT "Remplace les retours à la ligne (\r\n, \n, \r) par une chaîne de remplacement. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
