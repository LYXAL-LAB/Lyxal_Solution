-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/record_id.surql
-- Fonction : fn::validation_record_id
--
-- Valide qu'une valeur est un Record ID natif, facultativement d'une des
-- tables autorisées.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allowed_tables : option<array<string>> — tables autorisées (au moins une, noms valides), NONE pour toutes
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le Record ID d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou nom de table invalide
--
-- Exemple (dans une fonction de module)
--   LET $owner = fn::validation_record_id($params.owner, ["identity_user", "identity_team"]);
--   IF !$owner.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $owner.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record_id(
    $value: any,
    $allowed_tables: option<array<string>>
) -> object {
    LET $tables = IF $allowed_tables IS NONE { NONE } ELSE { array::map($allowed_tables, |$table| string::trim($table)) };
    IF $tables IS NOT NONE AND (array::len($tables) = 0 OR array::any($tables, |$table| !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$"))) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_record($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "record", actual: type::of($value) } };
    };
    IF $tables IS NOT NONE AND record::tb($value) NOT IN $tables { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $tables } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un Record ID natif, facultativement limité à des tables. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
