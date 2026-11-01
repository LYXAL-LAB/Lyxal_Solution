-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/hostname.surql
-- Fonction : fn::sanitize_hostname
--
-- Extrait un nom d'hôte d'une saisie (voir sanitize_domain), puis supprime
-- les caractères hors [a-z0-9.-].
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nom d'hôte
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_hostname($params.hostname);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_hostname(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(fn::sanitize_domain($value), <regex>"[^a-z0-9.-]", "");
}
COMMENT "Extrait un nom d'hôte d'une saisie (voir sanitize_domain), puis supprime les caractères hors [a-z0-9.-]. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
