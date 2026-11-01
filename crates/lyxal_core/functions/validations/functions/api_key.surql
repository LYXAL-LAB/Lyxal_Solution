-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/api_key.surql
-- Fonction : fn::validation_api_key
--
-- Valide une clé d'API : caractères [A-Za-z0-9._-], longueur bornée, préfixe
-- facultativement imposé.
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $min_length       : int — longueur minimale (>= 1)
--   $max_length       : int — longueur maximale (>= $min_length)
--   $allowed_prefixes : option<array<string>> — préfixes autorisés (au moins un), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1, $min_length > $max_length, ou liste de préfixes vide
--
-- Exemple (dans une fonction de module)
--   LET $key = fn::validation_api_key($params.api_key, 24, 128, ["sk_live_", "sk_test_"]);
--   IF !$key.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $key.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_api_key(
    $value: any,
    $min_length: int,
    $max_length: int,
    $allowed_prefixes: option<array<string>>
) -> object {
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    LET $prefixes = IF $allowed_prefixes IS NONE { NONE } ELSE { array::map($allowed_prefixes, |$prefix| string::trim($prefix)) };
    IF $prefixes IS NOT NONE AND (array::len($prefixes) = 0 OR array::any($prefixes, |$prefix| $prefix = "")) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[A-Za-z0-9._-]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "api_key" } };
    };
    IF $prefixes IS NOT NONE AND !array::any($prefixes, |$prefix| string::starts_with($clean, $prefix)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed_prefixes: $prefixes } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une clé d'API : caractères [A-Za-z0-9._-], longueur bornée, préfixe facultativement imposé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
