-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/recovery_code.surql
-- Fonction : fn::validation_recovery_code
--
-- Valide un code de récupération : N groupes de M caractères [A-Z0-9]
-- séparés par des tirets ; la valeur renvoyée est en majuscules.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $group_count  : int — nombre de groupes (>= 1)
--   $group_length : int — longueur de chaque groupe (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le code en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $group_count < 1 ou $group_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $code = fn::validation_recovery_code($params.code, 4, 5);
--   IF !$code.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $code.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_recovery_code(
    $value: any,
    $group_count: int,
    $group_length: int
) -> object {
    IF $group_count < 1 OR $group_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF array::len(string::split($clean, "-")) != $group_count
        OR !array::all(string::split($clean, "-"), |$group| string::len($group) = $group_length AND string::matches($group, "^[A-Z0-9]+$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "recovery_code", group_count: $group_count, group_length: $group_length } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un code de récupération : N groupes de M caractères [A-Z0-9] séparés par des tirets ; la valeur renvoyée est en majuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
