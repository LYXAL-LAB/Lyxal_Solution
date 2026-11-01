-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_tabs.surql
-- Fonction : fn::sanitize_remove_tabs
--
-- Remplace les tabulations par une chaîne de remplacement.
--
-- Paramètres
--   $value       : any — valeur à nettoyer (chaîne, ou NONE)
--   $replacement : string — texte de remplacement
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans tabulation
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $line = fn::sanitize_remove_tabs($params.line, " ");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_tabs(
    $value: any,
    $replacement: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, "\t", $replacement);
}
COMMENT "Remplace les tabulations par une chaîne de remplacement. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
