-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/fragment.surql
-- Fonction : fn::sanitize_fragment
--
-- Nettoie un fragment d'URL : « # » initial et caractères de contrôle
-- retirés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le fragment sans « # »
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_fragment($params.fragment);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_fragment(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::replace(string::trim($value), <regex>"^#", ""), <regex>"[\\x00-\\x1F\\x7F]", "");
}
COMMENT "Nettoie un fragment d'URL : « # » initial et caractères de contrôle retirés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
