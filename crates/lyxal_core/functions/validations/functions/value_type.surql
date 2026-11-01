-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/value_type.surql
-- Fonction : fn::validation_value_type
--
-- Valide que le type SurrealDB d'une valeur (type::of) est exactement le
-- type attendu.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $expected_type : string — type attendu tel que renvoyé par type::of (ex. "string", "int", "object"), insensible à la casse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expected_type vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_value_type($params.settings, "object");
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_value_type(
    $value: any,
    $expected_type: string
) -> object {
    LET $expected = string::lowercase(string::trim($expected_type));
    IF $expected = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    LET $actual = string::lowercase(type::of($value));
    IF $actual != $expected { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: $expected, actual: $actual } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide que type::of(valeur) est le type attendu. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
