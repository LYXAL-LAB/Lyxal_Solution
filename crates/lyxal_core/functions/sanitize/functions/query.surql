-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/query.surql
-- Fonction : fn::sanitize_query
--
-- Nettoie une chaîne de requête d'URL : « ? » initial, fragment (« #… ») et
-- caractères de contrôle retirés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la requête sans « ? »
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_query($params.query);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_query(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $query = string::replace(string::replace(string::trim($value), <regex>"^\\?", ""), <regex>"#.*$", "");
    RETURN string::replace($query, <regex>"[\\x00-\\x1F\\x7F]", "");
}
COMMENT "Nettoie une chaîne de requête d'URL : « ? » initial, fragment (« #… ») et caractères de contrôle retirés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
