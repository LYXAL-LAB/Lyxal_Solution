-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/datetime.surql
-- Fonction : fn::sanitize_datetime
--
-- Tronque un datetime à une précision donnée (ex. 1m, 1h).
--
-- Paramètres
--   $value     : any — valeur à nettoyer (datetime, ou NONE)
--   $precision : duration — précision (> 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le datetime tronqué
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $precision <= 0
--
-- Exemple
--   LET $at = fn::sanitize_datetime($params.at, 1m);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_datetime(
    $value: any,
    $precision: duration
) -> option<datetime> {
    IF $precision <= 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN time::floor($value, $precision);
}
COMMENT "Tronque un datetime à une précision donnée (ex. 1m, 1h). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
