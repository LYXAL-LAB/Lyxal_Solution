-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/surql_field.surql
-- Fonction : fn::validation_surql_field
--
-- Valide un nom de champ SurrealQL ([A-Za-z_][A-Za-z0-9_]*), longueur bornée
-- ; « id » accepté seulement si autorisé.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $allow_id   : bool — true pour accepter le champ « id »
--   $max_length : int — longueur maximale (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_FORBIDDEN
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $field = fn::validation_surql_field($params.field, false, 64);
--   IF !$field.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $field.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_field(
    $value: any,
    $allow_id: bool,
    $max_length: int
) -> object {
    IF $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[A-Za-z_][A-Za-z0-9_]*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_identifier" } };
    };
    IF !$allow_id AND $clean = "id" {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de champ SurrealQL ([A-Za-z_][A-Za-z0-9_]*), longueur bornée ; « id » accepté seulement si autorisé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
