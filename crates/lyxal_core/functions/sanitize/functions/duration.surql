-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/duration.surql
-- Fonction : fn::sanitize_duration
--
-- Tronque une durée à un multiple de la précision donnée.
--
-- Paramètres
--   $value     : any — valeur à nettoyer (duration, ou NONE)
--   $precision : duration — précision (> 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la durée tronquée
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $precision <= 0
--
-- Exemple
--   LET $timeout = fn::sanitize_duration($params.timeout, 1s);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_duration(
    $value: any,
    $precision: duration
) -> option<duration> {
    IF $precision <= 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_duration($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN duration::from_nanos(math::floor(duration::nanos($value) / duration::nanos($precision)) * duration::nanos($precision));
}
COMMENT "Tronque une durée à un multiple de la précision donnée. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
