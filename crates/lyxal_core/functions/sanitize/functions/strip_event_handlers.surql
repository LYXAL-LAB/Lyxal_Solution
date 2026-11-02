-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/strip_event_handlers.surql
-- Fonction : fn::sanitize_strip_event_handlers
--
-- Supprime les attributs de gestionnaire d'événement (onclick=…, onload=…).
-- Nettoyage lexical par expressions régulières : il ne remplace pas un
-- parseur HTML anti-XSS.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans attribut on*
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_strip_event_handlers($params.strip_event_handlers);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_strip_event_handlers(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"(?i)\\s+on[a-z]+\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)", "");
}
COMMENT "Supprime les attributs de gestionnaire d'événement (onclick=…, onload=…). Nettoyage lexical par expressions régulières : il ne remplace pas un parseur HTML anti-XSS. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
