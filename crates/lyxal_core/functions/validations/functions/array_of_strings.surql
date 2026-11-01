-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_of_strings.surql
-- Fonction : fn::validation_array_of_strings
--
-- Valide qu'une valeur est un tableau de chaînes ; chaque chaîne est
-- nettoyée de ses espaces périphériques, puis contrôlée (vide, longueurs).
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $allow_empty : bool — true pour accepter une chaîne vide après nettoyage
--   $min_length  : option<int> — longueur minimale de chaque chaîne (>= 0), NONE pour aucune
--   $max_length  : option<int> — longueur maximale de chaque chaîne (>= 0), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau des chaînes nettoyées, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne négative ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $roles = fn::validation_array_of_strings($params.roles, false, 1, 64);
--   IF !$roles.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $roles.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_of_strings(
    $value: any,
    $allow_empty: bool,
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
    IF !array::all($value, |$item| type::is_string($item)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "string" } };
    };
    LET $clean = array::map($value, |$item| string::trim($item));
    IF !$allow_empty AND array::any($clean, |$item| $item = "") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: { scope: "item" } }; };
    IF $min_length IS NOT NONE AND array::any($clean, |$item| string::len($item) < $min_length) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { scope: "item", min_length: $min_length } };
    };
    IF $max_length IS NOT NONE AND array::any($clean, |$item| string::len($item) > $max_length) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { scope: "item", max_length: $max_length } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un tableau de chaînes nettoyées et bornées. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
