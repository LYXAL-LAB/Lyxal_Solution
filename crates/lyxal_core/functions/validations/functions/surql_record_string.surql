-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/surql_record_string.surql
-- Fonction : fn::validation_surql_record_string
--
-- Valide une chaîne de Record ID SurrealQL (« table:id »,
-- string::is_record), facultativement d'une table donnée ; la chaîne n'est
-- pas convertie.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $expected_table : option<string> — table attendue (nom valide), NONE pour toutes
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expected_table qui n'est pas un nom de table
--
-- Exemple (dans une fonction de module)
--   LET $ref = fn::validation_surql_record_string($params.ref, "identity_user");
--   IF !$ref.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $ref.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_record_string(
    $value: any,
    $expected_table: option<string>
) -> object {
    LET $table = IF $expected_table IS NONE { NONE } ELSE { string::trim($expected_table) };
    IF $table IS NOT NONE AND !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::is_record($clean) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };
    };
    IF $table IS NOT NONE AND !string::is_record($clean, $table) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: [$table] } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne de Record ID SurrealQL (« table:id », string::is_record), facultativement d'une table donnée ; la chaîne n'est pas convertie. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
