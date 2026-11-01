-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/lyxal_permission_name.surql
-- Fonction : fn::validation_lyxal_permission_name
--
-- Valide un nom de permission Lyxal (au moins deux segments [a-z][a-z0-9_]*
-- séparés par des points, ex. booking.slot.read) ; action finale
-- facultativement limitée. Valeur renvoyée en minuscules.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $allowed_actions : option<array<string>> — actions (dernier segment) autorisées, au moins une, NONE pour toutes
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nom en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste d'actions vide ou action vide
--
-- Exemple (dans une fonction de module)
--   LET $permission = fn::validation_lyxal_permission_name($params.permission, ["read", "write"]);
--   IF !$permission.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $permission.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_permission_name(
    $value: any,
    $allowed_actions: option<array<string>>
) -> object {
    LET $actions = IF $allowed_actions IS NONE { NONE } ELSE { array::map($allowed_actions, |$item| string::lowercase(string::trim($item))) };
    IF $actions IS NOT NONE AND (array::len($actions) = 0 OR array::any($actions, |$item| $item = "")) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[a-z][a-z0-9_]*(?:\\.[a-z][a-z0-9_]*)+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_permission_name" } };
    };
    IF $actions IS NOT NONE AND array::last(string::split($clean, ".")) NOT IN $actions {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $actions } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de permission Lyxal (au moins deux segments [a-z][a-z0-9_]* séparés par des points, ex. booking.slot.read) ; action finale facultativement limitée. Valeur renvoyée en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
