-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/decimal.surql
-- Fonction : fn::validation_decimal
--
-- Valide qu'une valeur est de type décimal (decimal) et, facultativement,
-- comprise entre deux bornes incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<decimal> — borne minimale incluse, NONE pour aucune
--   $max_value : option<decimal> — borne maximale incluse, NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
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
--   LET $check = fn::validation_decimal($params.quantity, 1, 100);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_decimal(
    $value: any,
    $min_value: option<decimal>,
    $max_value: option<decimal>
) -> object {
    IF $min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_decimal($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "decimal", actual: type::of($value) } };
    };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur est de type decimal et comprise entre deux bornes facultatives. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
