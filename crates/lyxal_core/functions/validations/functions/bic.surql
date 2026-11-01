-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/bic.surql
-- Fonction : fn::validation_bic
--
-- Valide un code BIC / SWIFT (8 ou 11 caractères) ; pays (5e et 6e
-- caractères) facultativement limités. La valeur renvoyée est en majuscules.
--
-- Paramètres
--   $value             : any — valeur à contrôler
--   $allowed_countries : option<array<string>> — codes pays autorisés (au moins un, au bon format), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le BIC en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou code pays au mauvais format
--
-- Exemple (dans une fonction de module)
--   LET $bic = fn::validation_bic($params.bic, NONE);
--   IF !$bic.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $bic.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bic(
    $value: any,
    $allowed_countries: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_countries IS NONE { NONE } ELSE { array::map($allowed_countries, |$item| string::uppercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| !string::matches($item, "^[A-Z]{2}$"))) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[A-Z]{6}[A-Z0-9]{2}(?:[A-Z0-9]{3})?$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bic" } };
    };
    IF $allowed IS NOT NONE AND string::slice($clean, 4, 6) NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code BIC / SWIFT (8 ou 11 caractères) ; pays (5e et 6e caractères) facultativement limités. La valeur renvoyée est en majuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
