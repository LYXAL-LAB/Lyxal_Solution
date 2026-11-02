-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/html.surql
-- Fonction : fn::sanitize_html
--
-- Nettoie un fragment HTML : commentaires, scripts, styles, iframes, SVG,
-- gestionnaires d'événement et attributs dangereux retirés. Nettoyage
-- lexical par expressions régulières : il ne remplace pas un parseur HTML
-- anti-XSS.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le fragment nettoyé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_html($params.html);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_html(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $step1 = fn::sanitize_strip_svg(fn::sanitize_strip_iframes(fn::sanitize_strip_styles(fn::sanitize_strip_scripts(fn::sanitize_strip_comments($value)))));
    RETURN fn::sanitize_strip_dangerous_attributes(fn::sanitize_strip_event_handlers($step1));
}
COMMENT "Nettoie un fragment HTML : commentaires, scripts, styles, iframes, SVG, gestionnaires d'événement et attributs dangereux retirés. Nettoyage lexical par expressions régulières : il ne remplace pas un parseur HTML anti-XSS. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
