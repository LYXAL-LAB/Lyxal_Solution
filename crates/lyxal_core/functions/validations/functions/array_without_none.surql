-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_without_none.surql
-- Fonction : fn::validation_array_without_none
--
-- Valide qu'un tableau ne contient aucun élément NONE.
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
--     CORE_VALIDATION_REQUIRED
--
-- Exemple (dans une fonction de module)
--   LET $values = fn::validation_array_without_none($params.values);
--   IF !$values.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $values.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_without_none(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF array::any($value, |$item| $item IS NONE) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "item" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau sans élément NONE. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
