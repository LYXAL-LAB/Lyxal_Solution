-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_integers.surql
-- Fonction : fn::validation_array_integers
--
-- Valide qu'une valeur est un tableau d'entiers, chacun facultativement
-- compris entre deux bornes incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<int> — valeur minimale incluse de chaque élément, NONE pour aucune
--   $max_value : option<int> — valeur maximale incluse de chaque élément, NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_value > $max_value
--
-- Exemple (dans une fonction de module)
--   LET $quantities = fn::validation_array_integers($params.quantities, 1, NONE);
--   IF !$quantities.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $quantities.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_integers(
    $value: any,
    $min_value: option<int>,
    $max_value: option<int>
) -> object {
    IF $min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF !array::all($value, |$item| type::is_int($item)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "int" } };
    };
    IF $min_value IS NOT NONE AND array::any($value, |$item| $item < $min_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { scope: "item", min: $min_value } };
    };
    IF $max_value IS NOT NONE AND array::any($value, |$item| $item > $max_value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { scope: "item", max: $max_value } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau d'entiers bornés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
