-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/password_strength.surql
-- Fonction : fn::validation_password_strength
--
-- Valide la robustesse d'un mot de passe : longueur bornée (sans nettoyage)
-- et présence des classes de caractères exigées. Le mot de passe n'est
-- jamais renvoyé dans details.
--
-- Paramètres
--   $value             : any — valeur à contrôler
--   $min_length        : int — longueur minimale (>= 1)
--   $max_length        : int — longueur maximale (>= $min_length)
--   $require_uppercase : bool — exiger une majuscule
--   $require_lowercase : bool — exiger une minuscule
--   $require_digit     : bool — exiger un chiffre
--   $require_special   : bool — exiger un caractère spécial
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le mot de passe d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $password = fn::validation_password_strength($params.password, 12, 128, true, true, true, false);
--   IF !$password.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $password.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_password_strength(
    $value: any,
    $min_length: int,
    $max_length: int,
    $require_uppercase: bool,
    $require_lowercase: bool,
    $require_digit: bool,
    $require_special: bool
) -> object {
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $length = string::len($value);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    LET $missing = array::filter([
        IF $require_uppercase AND !string::matches($value, "[A-Z]") { "uppercase" },
        IF $require_lowercase AND !string::matches($value, "[a-z]") { "lowercase" },
        IF $require_digit AND !string::matches($value, "[0-9]") { "digit" },
        IF $require_special AND !string::matches($value, "[^A-Za-z0-9]") { "special" }
    ], |$item| $item IS NOT NONE);
    IF array::len($missing) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "password", missing: $missing } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide la robustesse d'un mot de passe. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
