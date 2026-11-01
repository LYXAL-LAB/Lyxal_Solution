-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_length.surql
-- Fonction : fn::validation_array_length
--
-- Valide qu'une valeur est un tableau dont le nombre d'éléments est compris
-- entre deux bornes facultatives.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : option<int> — nombre minimal d'éléments (>= 0), NONE pour aucun
--   $max_length : option<int> — nombre maximal d'éléments (>= 0), NONE pour aucun
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
--   CORE_INVALID_ARGUMENT : borne négative ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $items = fn::validation_array_length($params.items, 1, 50);
--   IF !$items.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $items.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_length(
    $value: any,
    $min_length: option<int>,
    $max_length: option<int>
) -> object {
    IF ($min_length IS NOT NONE AND $min_length < 0) OR ($max_length IS NOT NONE AND $max_length < 0) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $min_length IS NOT NONE AND $max_length IS NOT NONE AND $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    LET $length = array::len($value);
    IF $min_length IS NOT NONE AND $length < $min_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } };
    };
    IF $max_length IS NOT NONE AND $length > $max_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau borné en nombre d'éléments. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
