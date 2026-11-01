-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/language_code.surql
-- Fonction : fn::validation_language_code
--
-- Valide un code langue ISO 639 (deux lettres, ou trois si autorisé) ; la
-- valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $allow_alpha3  : bool — true pour accepter les codes à trois lettres
--   $allowed_codes : option<array<string>> — codes autorisés (au moins un, au bon format), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le code en minuscules, code = NONE
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
--   LET $lang = fn::validation_language_code($params.language, false, ["fr", "en"]);
--   IF !$lang.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $lang.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_language_code(
    $value: any,
    $allow_alpha3: bool,
    $allowed_codes: option<array<string>>
) -> object {
    LET $pattern = IF $allow_alpha3 { "^[a-z]{2,3}$" } ELSE { "^[a-z]{2}$" };
    LET $allowed = IF $allowed_codes IS NONE { NONE } ELSE { array::map($allowed_codes, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| !string::matches($item, $pattern))) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, $pattern) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "language_code" } };
    };
    IF $allowed IS NOT NONE AND $clean NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code langue ISO 639 (deux lettres, ou trois si autorisé) ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
