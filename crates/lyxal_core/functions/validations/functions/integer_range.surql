-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/integer_range.surql
-- Fonction : fn::validation_integer_range
--
-- Valide un intervalle d'entiers [min, max] fourni par l'utilisateur : deux
-- entiers, dans l'ordre, égaux seulement si autorisé.
--
-- Paramètres
--   $min_value   : any — borne basse saisie
--   $max_value   : any — borne haute saisie
--   $allow_equal : bool — true pour accepter min = max
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { min_value, max_value, span } (span = max_value - min_value), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_RANGE_ORDER
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_integer_range($params.min_seats, $params.max_seats, true);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_integer_range(
    $min_value: any,
    $max_value: any,
    $allow_equal: bool
) -> object {
    IF $min_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "min" } }; };
    IF type::is_null($min_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "min" } }; };
    IF !type::is_int($min_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "min", expected: "int", actual: type::of($min_value) } };
    };
    IF $max_value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "max" } }; };
    IF type::is_null($max_value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "max" } }; };
    IF !type::is_int($max_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "max", expected: "int", actual: type::of($max_value) } };
    };
    IF $max_value < $min_value OR (!$allow_equal AND $max_value = $min_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { min_value: $min_value, max_value: $max_value, allow_equal: $allow_equal } };
    };
    RETURN { valid: true, value: { min_value: $min_value, max_value: $max_value, span: $max_value - $min_value }, code: NONE, details: {} };
}
COMMENT "Valide un intervalle d'entiers ordonné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
