-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_code.surql
-- Fonction : fn::sanitize_markdown_code
--
-- Supprime les blocs de code Markdown (``` … ```) et les accents graves du
-- code en ligne, en gardant son contenu.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans code Markdown
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_code($params.markdown_code);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_code(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::replace($value, <regex>"(?s)```.*?```", ""), "`", "");
}
COMMENT "Supprime les blocs de code Markdown (``` … ```) et les accents graves du code en ligne, en gardant son contenu. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
