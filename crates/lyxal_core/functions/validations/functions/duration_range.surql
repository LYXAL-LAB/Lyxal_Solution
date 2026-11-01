-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/duration_range.surql
-- Fonction : fn::validation_duration_range
--
-- Valide un intervalle de durées [min, max] fourni par l'utilisateur : deux
-- durées dans l'ordre, égales seulement si autorisé, d'écart facultativement
-- borné.
--
-- Paramètres
--   $min_value   : any — durée basse
--   $max_value   : any — durée haute
--   $allow_exact : bool — true pour accepter min = max
--   $min_span    : option<duration> — écart minimal, NONE pour aucun
--   $max_span    : option<duration> — écart maximal, NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { min_duration, max_duration, span }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_RANGE_ORDER
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_span > $max_span, ou $max_span = 0ns sans $allow_exact
--
-- Exemple (dans une fonction de module)
--   LET $range = fn::validation_duration_range($params.min_duration, $params.max_duration, false, NONE, 8h);
--   IF !$range.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $range.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_duration_range(
    $min_value: any,
    $max_value: any,
    $allow_exact: bool,
    $min_span: option<duration>,
    $max_span: option<duration>
) -> object {
    IF $min_span IS NOT NONE AND $max_span IS NOT NONE AND $min_span > $max_span { THROW "CORE_INVALID_ARGUMENT"; };
    IF !$allow_exact AND $max_span IS NOT NONE AND $max_span = 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $min_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "min" } }; };
    IF type::is_null($min_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "min" } }; };
    IF !type::is_duration($min_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "min", expected: "duration", actual: type::of($min_value) } };
    };
    IF $max_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "max" } }; };
    IF type::is_null($max_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "max" } }; };
    IF !type::is_duration($max_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "max", expected: "duration", actual: type::of($max_value) } };
    };
    IF $max_value < $min_value OR (!$allow_exact AND $max_value = $min_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { min_value: $min_value, max_value: $max_value, allow_equal: $allow_exact } };
    };
    LET $span = $max_value - $min_value;
    IF $min_span IS NOT NONE AND $span < $min_span { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_span: $min_span, span: $span } }; };
    IF $max_span IS NOT NONE AND $span > $max_span { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_span: $max_span, span: $span } }; };
    RETURN { valid: true, value: { min_duration: $min_value, max_duration: $max_value, span: $span }, code: NONE, details: {} };
}
COMMENT "Valide un intervalle de durées ordonné et borné en écart. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
