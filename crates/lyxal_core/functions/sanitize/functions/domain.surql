-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/domain.surql
-- Fonction : fn::sanitize_domain
--
-- Extrait un domaine d'une saisie : minuscules, schéma http(s):// retiré,
-- chemin et port retirés, points finaux retirés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le domaine
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_domain($params.domain);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_domain(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $host = string::split(string::split(string::replace(string::lowercase(string::trim($value)), <regex>"^https?://", ""), "/")[0], ":")[0];
    RETURN string::replace($host, <regex>"\\.+$", "");
}
COMMENT "Extrait un domaine d'une saisie : minuscules, schéma http(s):// retiré, chemin et port retirés, points finaux retirés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
