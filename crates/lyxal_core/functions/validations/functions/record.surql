-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/record.surql
-- Fonction : fn::validation_record
--
-- Construit et valide un Record ID d'une table attendue à partir d'une
-- chaîne "table:id" ou "id" (espaces périphériques retirés).
--
-- Paramètres
--   $value          : any — chaîne à convertir
--   $expected_table : string — table attendue (nom de table valide)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le Record ID construit, code = NONE
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
--   LET $team = fn::validation_record($params.team_id, "booking_team");
--   IF !$team.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $team.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record(
    $value: any,
    $expected_table: string
) -> object {
    LET $table = string::trim($expected_table);
    IF !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $parts = array::map(string::split($clean, ":"), |$part| string::trim($part));
    IF array::len($parts) > 2 OR array::any($parts, |$part| $part = "") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } }; };
    IF array::len($parts) = 2 AND $parts[0] != $table { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: [$table] } }; };
    RETURN { valid: true, value: type::record($table, $parts[array::len($parts) - 1]), code: NONE, details: {} };
}
COMMENT "Construit un Record ID de la table attendue depuis une chaîne. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
