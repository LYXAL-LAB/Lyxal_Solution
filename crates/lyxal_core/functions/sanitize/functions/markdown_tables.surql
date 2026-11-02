-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_tables.surql
-- Fonction : fn::sanitize_markdown_tables
--
-- Supprime les lignes de séparation des tableaux Markdown (---) et remplace
-- les « | » par des espaces.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans syntaxe de tableau
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_tables($params.markdown_tables);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_tables(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::replace($value, <regex>"(?m)^\\s*\\|?\\s*:?-{3,}.*$", ""), "|", " ");
}
COMMENT "Supprime les lignes de séparation des tableaux Markdown (---) et remplace les « | » par des espaces. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
