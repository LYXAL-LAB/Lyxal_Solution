-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/schedule.surql
-- Fonction : fn::sanitize_schedule
--
-- Calcule un créneau à partir d'un début arrondi (vers le bas) à une
-- précision et d'une durée.
--
-- Paramètres
--   $value    : any — début (datetime, ou NONE)
--   $duration : duration — durée du créneau
--   $round_to : duration — précision de l'arrondi (> 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : { start_at, end_at, duration }
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $round_to <= 0
--
-- Exemple
--   LET $slot = fn::sanitize_schedule($params.start_at, 1h, 15m);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schedule(
    $value: any,
    $duration: duration,
    $round_to: duration
) -> option<object> {
    IF $round_to <= 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $start = time::floor($value, $round_to);
    RETURN { start_at: $start, end_at: $start + $duration, duration: $duration };
}
COMMENT "Calcule un créneau à partir d'un début arrondi (vers le bas) à une précision et d'une durée. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
