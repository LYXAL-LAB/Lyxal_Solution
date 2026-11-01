-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/time_of_day_range.surql
-- Fonction : fn::validation_time_of_day_range
--
-- Valide une plage horaire exprimée en minutes depuis minuit (0 à 1439) ;
-- une plage qui passe minuit est acceptée seulement si autorisé.
--
-- Paramètres
--   $start_minute        : any — minute de début (0 à 1439)
--   $end_minute          : any — minute de fin (0 à 1439)
--   $allow_overnight     : bool — true pour accepter une fin antérieure au début (plage qui passe minuit)
--   $allow_zero_duration : bool — true pour accepter début = fin
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { start_minute, end_minute, duration_minutes, overnight }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--     CORE_VALIDATION_RANGE_ORDER
--
-- Exemple (dans une fonction de module)
--   LET $hours = fn::validation_time_of_day_range($params.open_minute, $params.close_minute, false, false);
--   IF !$hours.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $hours.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_of_day_range(
    $start_minute: any,
    $end_minute: any,
    $allow_overnight: bool,
    $allow_zero_duration: bool
) -> object {
    IF $start_minute IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } }; };
    IF type::is_null($start_minute) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "start" } }; };
    IF !type::is_int($start_minute) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "start", expected: "int", actual: type::of($start_minute) } };
    };
    IF $start_minute < 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "start", min: 0 } }; };
    IF $start_minute > 1439 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "start", max: 1439 } }; };
    IF $end_minute IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "end" } }; };
    IF type::is_null($end_minute) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "end" } }; };
    IF !type::is_int($end_minute) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "int", actual: type::of($end_minute) } };
    };
    IF $end_minute < 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "end", min: 0 } }; };
    IF $end_minute > 1439 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "end", max: 1439 } }; };
    IF (!$allow_zero_duration AND $end_minute = $start_minute) OR (!$allow_overnight AND $end_minute < $start_minute) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: $start_minute, end: $end_minute, allow_equal: $allow_zero_duration, allow_overnight: $allow_overnight } };
    };
    LET $overnight = $end_minute < $start_minute;
    LET $duration_minutes = IF $overnight { 1440 - $start_minute + $end_minute } ELSE { $end_minute - $start_minute };
    RETURN { valid: true, value: { start_minute: $start_minute, end_minute: $end_minute, duration_minutes: $duration_minutes, overnight: $overnight }, code: NONE, details: {} };
}
COMMENT "Valide une plage horaire en minutes depuis minuit. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
