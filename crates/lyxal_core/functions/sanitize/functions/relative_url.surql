-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/relative_url.surql
-- Fonction : fn::sanitize_relative_url
--
-- Rend une URL relative à la racine : schéma et hôte retirés, « / » initial
-- unique garanti.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le chemin commençant par « / »
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_relative_url($params.relative_url);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_relative_url(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $path = string::replace(string::replace(string::trim($value), <regex>"^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]*", ""), <regex>"^/+", "/");
    RETURN IF string::starts_with($path, "/") { $path } ELSE { "/" + $path };
}
COMMENT "Rend une URL relative à la racine : schéma et hôte retirés, « / » initial unique garanti. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
