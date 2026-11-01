-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/currency_code.surql
-- Fonction : fn::validation_currency_code
--
-- Valide un code devise ISO 4217 (trois lettres) ; la valeur renvoyée est en
-- majuscules. L'existence du code n'est vérifiée que par la liste
-- facultative.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $allowed_codes : option<array<string>> — codes devise autorisés (au moins un, au bon format), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le code en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou code au mauvais format
--
-- Exemple (dans une fonction de module)
--   LET $code = fn::validation_currency_code($params.code, NONE);
--   IF !$code.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $code.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_currency_code(
    $value: any,
    $allowed_codes: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_codes IS NONE { NONE } ELSE { array::map($allowed_codes, |$item| string::uppercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| !string::matches($item, "^[A-Z]{3}$"))) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[A-Z]{3}$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "currency_code" } };
    };
    IF $allowed IS NOT NONE AND $clean NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code devise ISO 4217 (trois lettres) ; la valeur renvoyée est en majuscules. L'existence du code n'est vérifiée que par la liste facultative. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
