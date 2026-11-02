-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_lists.surql
-- Fonction : fn::sanitize_markdown_lists
--
-- Supprime les puces et numéros de liste Markdown en début de ligne (-, +,
-- *, 1.).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans puce
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_lists($params.markdown_lists);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_lists(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"(?m)^\\s*(?:[-+*]|[0-9]+\\.)\\s+", "");
}
COMMENT "Supprime les puces et numéros de liste Markdown en début de ligne (-, +, *, 1.). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
