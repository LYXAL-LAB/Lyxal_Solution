-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/strip_dangerous_attributes.surql
-- Fonction : fn::sanitize_strip_dangerous_attributes
--
-- Supprime les attributs style et srcdoc et neutralise les liens javascript:
-- (href et src remplacés par "#"). Nettoyage lexical par expressions
-- régulières : il ne remplace pas un parseur HTML anti-XSS.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans attribut dangereux
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_strip_dangerous_attributes($params.strip_dangerous_attributes);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_strip_dangerous_attributes(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $without_style = string::replace($value, <regex>"(?i)\\s+(style|srcdoc)\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)", "");
    LET $safe_href = string::replace($without_style, <regex>"(?i)href\\s*=\\s*(\"\\s*javascript:[^\"]*\"|'\\s*javascript:[^']*')", "href=\"#\"");
    RETURN string::replace($safe_href, <regex>"(?i)src\\s*=\\s*(\"\\s*javascript:[^\"]*\"|'\\s*javascript:[^']*')", "src=\"#\"");
}
COMMENT "Supprime les attributs style et srcdoc et neutralise les liens javascript: (href et src remplacés par \"#\"). Nettoyage lexical par expressions régulières : il ne remplace pas un parseur HTML anti-XSS. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
