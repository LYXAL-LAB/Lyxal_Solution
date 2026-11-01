-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/rfc3339.surql
-- Fonction : fn::sanitize_rfc3339
--
-- Formate un datetime en texte RFC 3339 / ISO 8601 UTC
-- (AAAA-MM-JJTHH:MM:SS[.fff]Z).
--
-- Paramètres
--   $value : any — valeur à nettoyer (datetime, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte RFC 3339
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_rfc3339($params.rfc3339);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_rfc3339(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN time::format($value, "%Y-%m-%dT%H:%M:%S%.fZ");
}
COMMENT "Formate un datetime en texte RFC 3339 / ISO 8601 UTC (AAAA-MM-JJTHH:MM:SS[.fff]Z). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
