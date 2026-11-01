-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/tuple_types.surql
-- Fonction : fn::validation_tuple_types
--
-- Valide qu'un tableau a exactement autant d'éléments que de types attendus,
-- chaque élément ayant le type (type::of) de même rang.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $expected_types : array<string> — types attendus dans l'ordre (au moins un, tels que renvoyés par type::of)
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
--   CORE_INVALID_ARGUMENT : liste vide ou type vide
--
-- Exemple (dans une fonction de module)
--   LET $pair = fn::validation_tuple_types($params.pair, ["string", "int"]);
--   IF !$pair.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $pair.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_tuple_types(
    $value: any,
    $expected_types: array<string>
) -> object {
    LET $types = array::map($expected_types, |$type_name| string::lowercase(string::trim($type_name)));
    IF array::len($types) = 0 OR array::any($types, |$type_name| $type_name = "") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    LET $length = array::len($value);
    IF $length < array::len($types) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: array::len($types), length: $length } };
    };
    IF $length > array::len($types) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: array::len($types), length: $length } };
    };
    IF !array::all(<array> (0..$length), |$index| string::lowercase(type::of($value[$index])) = $types[$index]) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: $types } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau typé élément par élément. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
