-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/money.surql
-- Fonction : fn::validation_money
--
-- Valide un montant monétaire : decimal, facultativement borné, avec au plus
-- N décimales significatives.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<decimal> — montant minimal inclus, NONE pour aucun
--   $max_value : option<decimal> — montant maximal inclus, NONE pour aucun
--   $max_scale : int — nombre maximal de décimales (>= 0)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le decimal d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_scale < 0 ou $min_value > $max_value
--
-- Exemple (dans une fonction de module)
--   LET $amount = fn::validation_money($params.amount, 0dec, NONE, 2);
--   IF !$amount.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $amount.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_money(
    $value: any,
    $min_value: option<decimal>,
    $max_value: option<decimal>,
    $max_scale: int
) -> object {
    IF $max_scale < 0 OR ($min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_decimal($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "decimal", actual: type::of($value) } };
    };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    LET $parts = string::split(<string> $value, ".");
    LET $scale = IF array::len($parts) = 2 { string::len($parts[1]) } ELSE { 0 };
    IF $scale > $max_scale { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { max_scale: $max_scale, scale: $scale } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un montant decimal borné et à précision limitée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
