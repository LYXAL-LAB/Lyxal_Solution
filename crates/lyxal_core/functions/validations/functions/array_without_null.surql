-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_without_null.surql
-- Fonction : fn::validation_array_without_null
--
-- Valide qu'un tableau ne contient aucun élément NULL.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NULL
--
-- Exemple (dans une fonction de module)
--   LET $values = fn::validation_array_without_null($params.values);
--   IF !$values.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $values.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_without_null(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF array::any($value, |$item| type::is_null($item)) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { scope: "item" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau sans élément NULL. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
