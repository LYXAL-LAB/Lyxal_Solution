-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_html.surql
-- Fonction : fn::sanitize_markdown_html
--
-- Supprime les balises HTML d'un texte Markdown (même effet que
-- sanitize_strip_html).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans balise
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_html($params.markdown_html);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_html(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN fn::sanitize_strip_html($value);
}
COMMENT "Supprime les balises HTML d'un texte Markdown (même effet que sanitize_strip_html). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
