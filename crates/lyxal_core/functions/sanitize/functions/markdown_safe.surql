-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_safe.surql
-- Fonction : fn::sanitize_markdown_safe
--
-- Rend un texte Markdown sûr à afficher sans le convertir : HTML dangereux
-- retiré (voir sanitize_html) et liens javascript: ou data: remplacés par
-- about:blank. Nettoyage lexical par expressions régulières : il ne remplace
-- pas un parseur HTML anti-XSS.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le Markdown nettoyé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_safe($params.markdown_safe);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_safe(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(fn::sanitize_html($value), <regex>"(?i)\\]\\(\\s*(javascript|data):(\\S*\\s+(\"[^\"]*\"|'[^']*')\\s*\\)|\\S*\\))", "](about:blank)");
}
COMMENT "Rend un texte Markdown sûr à afficher sans le convertir : HTML dangereux retiré (voir sanitize_html) et liens javascript: ou data: remplacés par about:blank. Nettoyage lexical par expressions régulières : il ne remplace pas un parseur HTML anti-XSS. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
