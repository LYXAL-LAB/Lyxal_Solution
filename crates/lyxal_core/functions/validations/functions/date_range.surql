-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/date_range.surql
-- Fonction : fn::validation_date_range
--
-- Valide un intervalle de dates calendaires [début, fin] : deux dates à
-- minuit, dans l'ordre, de même jour seulement si autorisé, et d'une durée
-- en jours facultativement bornée.
--
-- Paramètres
--   $start_value    : any — date de début
--   $end_value      : any — date de fin
--   $allow_same_day : bool — true pour accepter début = fin
--   $min_days       : option<int> — nombre minimal de jours (>= 0), NONE pour aucun
--   $max_days       : option<int> — nombre maximal de jours (>= 0), NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { start_date, end_date, days }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_RANGE_ORDER
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nombre de jours négatif ou $min_days > $max_days
--
-- Exemple (dans une fonction de module)
--   LET $stay = fn::validation_date_range($params.check_in, $params.check_out, false, 1, 30);
--   IF !$stay.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $stay.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_date_range(
    $start_value: any,
    $end_value: any,
    $allow_same_day: bool,
    $min_days: option<int>,
    $max_days: option<int>
) -> object {
    IF ($min_days IS NOT NONE AND $min_days < 0) OR ($max_days IS NOT NONE AND $max_days < 0) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $min_days IS NOT NONE AND $max_days IS NOT NONE AND $min_days > $max_days { THROW "CORE_INVALID_ARGUMENT"; };
    IF $start_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } }; };
    IF type::is_null($start_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "start" } }; };
    IF !type::is_datetime($start_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "start", expected: "datetime", actual: type::of($start_value) } };
    };
    IF time::format($start_value, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "start", expected: "date" } }; };
    IF $end_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "end" } }; };
    IF type::is_null($end_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "end" } }; };
    IF !type::is_datetime($end_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "datetime", actual: type::of($end_value) } };
    };
    IF time::format($end_value, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "end", expected: "date" } }; };
    IF $end_value < $start_value OR (!$allow_same_day AND $end_value = $start_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: $start_value, end: $end_value, allow_equal: $allow_same_day } };
    };
    LET $days = duration::days($end_value - $start_value);
    IF $min_days IS NOT NONE AND $days < $min_days { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_days: $min_days, days: $days } }; };
    IF $max_days IS NOT NONE AND $days > $max_days { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_days: $max_days, days: $days } }; };
    RETURN { valid: true, value: { start_date: $start_value, end_date: $end_value, days: $days }, code: NONE, details: {} };
}
COMMENT "Valide un intervalle de dates ordonné et borné en jours. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
