-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/allowed_types.surql
-- Fonction : fn::validation_allowed_types
--
-- Valide que le type SurrealDB d'une valeur (type::of) fait partie d'une
-- liste de types autorisés.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $allowed_types : array<string> — types autorisés tels que renvoyés par type::of, insensibles à la casse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou contenant un type vide
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_allowed_types($params.amount, ["int", "decimal"]);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_allowed_types(
    $value: any,
    $allowed_types: array<string>
) -> object {
    LET $allowed = array::map($allowed_types, |$type_name| string::lowercase(string::trim($type_name)));
    IF array::len($allowed) = 0 OR array::any($allowed, |$type_name| $type_name = "") {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    LET $actual = string::lowercase(type::of($value));
    IF $actual NOT IN $allowed { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: $allowed, actual: $actual } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide que type::of(valeur) fait partie des types autorisés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
