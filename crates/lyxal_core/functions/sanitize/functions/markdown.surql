-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown.surql
-- Fonction : fn::sanitize_markdown
--
-- Convertit un texte Markdown en texte brut : images, liens, code, titres,
-- citations, listes, tableaux et balises HTML retirés (texte conservé).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte brut
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown($params.markdown);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $inline = fn::sanitize_markdown_code(fn::sanitize_markdown_links(fn::sanitize_markdown_images($value)));
    LET $blocks = fn::sanitize_markdown_tables(fn::sanitize_markdown_lists(fn::sanitize_markdown_quotes(fn::sanitize_markdown_headers($inline))));
    RETURN fn::sanitize_strip_html($blocks);
}
COMMENT "Convertit un texte Markdown en texte brut : images, liens, code, titres, citations, listes, tableaux et balises HTML retirés (texte conservé). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
