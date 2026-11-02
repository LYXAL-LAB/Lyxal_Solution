-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_quotes.surql
-- Fonction : fn::sanitize_markdown_quotes
--
-- Supprime les marqueurs de citation Markdown (> en début de ligne).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans marqueur de citation
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_quotes($params.markdown_quotes);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_quotes(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"(?m)^\\s*>\\s?", "");
}
COMMENT "Supprime les marqueurs de citation Markdown (> en début de ligne). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
