-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/calendar.surql
-- Fonction : fn::sanitize_calendar
--
-- Ramène un datetime au début de l'unité calendaire donnée (time::group).
--
-- Paramètres
--   $value       : any — valeur à nettoyer (datetime, ou NONE)
--   $granularity : string — "year", "month", "day", "hour", "minute" ou "second", insensible à la casse
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le datetime regroupé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : unité inconnue
--
-- Exemple
--   LET $month = fn::sanitize_calendar($params.at, "month");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_calendar(
    $value: any,
    $granularity: string
) -> option<datetime> {
    LET $unit = string::lowercase(string::trim($granularity));
    IF $unit NOT IN ["year", "month", "day", "hour", "minute", "second"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN time::group($value, $unit);
}
COMMENT "Ramène un datetime au début de l'unité calendaire donnée (time::group). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
