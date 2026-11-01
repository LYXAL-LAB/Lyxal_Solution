-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/http_method.surql
-- Fonction : fn::validation_http_method
--
-- Valide une méthode HTTP (lettres uniquement), facultativement parmi une
-- liste ; la valeur renvoyée est en majuscules.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $allowed_methods : option<array<string>> — méthodes autorisés (au moins un), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la méthode en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou valeur vide
--
-- Exemple (dans une fonction de module)
--   LET $method = fn::validation_http_method($params.method, ["GET", "POST"]);
--   IF !$method.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $method.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_http_method(
    $value: any,
    $allowed_methods: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_methods IS NONE { NONE } ELSE { array::map($allowed_methods, |$item| string::uppercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| $item = "")) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[A-Z]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "http_method" } };
    };
    IF $allowed IS NOT NONE AND $clean NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une méthode HTTP (lettres uniquement), facultativement parmi une liste ; la valeur renvoyée est en majuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
