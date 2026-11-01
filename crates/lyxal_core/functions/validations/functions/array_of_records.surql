-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_of_records.surql
-- Fonction : fn::validation_array_of_records
--
-- Valide qu'une valeur est un tableau de Record IDs, facultativement tous
-- d'une table donnée et tous existants en base.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $expected_table : option<string> — table attendue pour chaque élément, NONE pour toutes
--   $require_exists : bool — true pour exiger que chaque enregistrement existe (lecture en base)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_NOT_FOUND
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expected_table vide ou qui n'est pas un nom de table
--
-- Exemple (dans une fonction de module)
--   LET $members = fn::validation_array_of_records($params.members, "identity_user", true);
--   IF !$members.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $members.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_of_records(
    $value: any,
    $expected_table: option<string>,
    $require_exists: bool
) -> object {
    LET $table = IF $expected_table IS NONE { NONE } ELSE { string::trim($expected_table) };
    IF $table IS NOT NONE AND !string::matches($table, "^[A-Za-z_][A-Za-z0-9_]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF !array::all($value, |$item| type::is_record($item)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "record" } };
    };
    IF $table IS NOT NONE AND array::any($value, |$item| record::tb($item) != $table) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "item", allowed: [$table] } };
    };
    IF $require_exists AND array::any($value, |$item| !record::exists($item)) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: { scope: "item" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau de Record IDs (table et existence facultatives). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
