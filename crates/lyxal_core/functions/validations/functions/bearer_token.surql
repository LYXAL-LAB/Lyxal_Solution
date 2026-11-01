-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/bearer_token.surql
-- Fonction : fn::validation_bearer_token
--
-- Valide un en-tête d'autorisation « Bearer <jeton> » et renvoie le jeton
-- seul, dont la longueur est bornée.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : int — longueur minimale (>= 1)
--   $max_length : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le jeton, sans le préfixe « Bearer », code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $raw_token = fn::validation_bearer_token($headers.authorization, 16, 4096);
--   IF !$raw_token.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $raw_token.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bearer_token(
    $value: any,
    $min_length: int,
    $max_length: int
) -> object {
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::starts_with($clean, "Bearer ") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bearer_token" } }; };
    LET $raw_token = string::trim(string::slice($clean, 7));
    IF !string::matches($raw_token, "^[A-Za-z0-9._~+/-]+=*$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bearer_token" } }; };
    LET $length = string::len($raw_token);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    RETURN { valid: true, value: $raw_token, code: NONE, details: {} };
}
COMMENT "Valide un en-tête Bearer et renvoie le jeton. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
