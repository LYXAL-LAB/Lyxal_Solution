-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/tuple_length.surql
-- Fonction : fn::validation_tuple_length
--
-- Valide qu'une valeur est un tableau d'exactement N éléments.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $expected_length : int — nombre exact d'éléments (>= 0)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expected_length < 0
--
-- Exemple (dans une fonction de module)
--   LET $point = fn::validation_tuple_length($params.point, 2);
--   IF !$point.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $point.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_tuple_length(
    $value: any,
    $expected_length: int
) -> object {
    IF $expected_length < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    LET $length = array::len($value);
    IF $expected_length IS NOT NONE AND $length < $expected_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $expected_length, length: $length } };
    };
    IF $expected_length IS NOT NONE AND $length > $expected_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $expected_length, length: $length } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau d'exactement N éléments. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
