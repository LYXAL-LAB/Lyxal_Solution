-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/time_range.surql
-- Fonction : fn::validation_time_range
--
-- Valide un intervalle d'instants [début, fin] : deux datetime dans l'ordre,
-- de durée nulle seulement si autorisé, et de durée facultativement bornée.
--
-- Paramètres
--   $start_value         : any — instant de début
--   $end_value           : any — instant de fin
--   $allow_zero_duration : bool — true pour accepter début = fin
--   $min_duration        : option<duration> — durée minimale, NONE pour aucune
--   $max_duration        : option<duration> — durée maximale, NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { start_at, end_at, duration }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_RANGE_ORDER
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_duration > $max_duration, ou $max_duration = 0ns sans $allow_zero_duration
--
-- Exemple (dans une fonction de module)
--   LET $slot = fn::validation_time_range($params.start_at, $params.end_at, false, 15m, 8h);
--   IF !$slot.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $slot.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_range(
    $start_value: any,
    $end_value: any,
    $allow_zero_duration: bool,
    $min_duration: option<duration>,
    $max_duration: option<duration>
) -> object {
    IF $min_duration IS NOT NONE AND $max_duration IS NOT NONE AND $min_duration > $max_duration { THROW "CORE_INVALID_ARGUMENT"; };
    IF !$allow_zero_duration AND $max_duration IS NOT NONE AND $max_duration = 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $start_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } }; };
    IF type::is_null($start_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "start" } }; };
    IF !type::is_datetime($start_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "start", expected: "datetime", actual: type::of($start_value) } };
    };
    IF $end_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "end" } }; };
    IF type::is_null($end_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "end" } }; };
    IF !type::is_datetime($end_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "datetime", actual: type::of($end_value) } };
    };
    IF $end_value < $start_value OR (!$allow_zero_duration AND $end_value = $start_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: $start_value, end: $end_value, allow_equal: $allow_zero_duration } };
    };
    LET $duration = $end_value - $start_value;
    IF $min_duration IS NOT NONE AND $duration < $min_duration { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_duration: $min_duration, duration: $duration } }; };
    IF $max_duration IS NOT NONE AND $duration > $max_duration { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_duration: $max_duration, duration: $duration } }; };
    RETURN { valid: true, value: { start_at: $start_value, end_at: $end_value, duration: $duration }, code: NONE, details: {} };
}
COMMENT "Valide un intervalle d'instants ordonné et borné en durée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
