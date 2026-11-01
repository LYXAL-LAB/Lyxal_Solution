-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/lyxal_role_name.surql
-- Fonction : fn::validation_lyxal_role_name
--
-- Valide un nom de rôle Lyxal : [a-z][a-z0-9_]* sans « _ » final, longueur
-- bornée, hors rôles réservés ; la valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $reserved_roles : option<array<string>> — rôles réservés, refusés (NONE pour aucun)
--   $min_length     : int — longueur minimale (>= 1)
--   $max_length     : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le rôle en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_FORBIDDEN
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $role = fn::validation_lyxal_role_name($params.role, ["owner", "system"], 2, 64);
--   IF !$role.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $role.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_role_name(
    $value: any,
    $reserved_roles: option<array<string>>,
    $min_length: int,
    $max_length: int
) -> object {
    LET $reserved = IF $reserved_roles IS NONE { [] } ELSE { array::map($reserved_roles, |$item| string::lowercase(string::trim($item))) };
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[a-z][a-z0-9_]*[a-z0-9]$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_role_name" } };
    };
    IF $clean IN $reserved {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de rôle Lyxal : [a-z][a-z0-9_]* sans « _ » final, longueur bornée, hors rôles réservés ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
