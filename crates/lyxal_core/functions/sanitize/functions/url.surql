-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/url.surql
-- Fonction : fn::sanitize_url
--
-- Nettoie une URL : espaces périphériques retirés, puis tout caractère de
-- contrôle ou espace interne supprimé.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'URL nettoyée
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_url($params.url);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_url(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::trim($value), <regex>"[\\x00-\\x20\\x7F]", "");
}
COMMENT "Nettoie une URL : espaces périphériques retirés, puis tout caractère de contrôle ou espace interne supprimé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
