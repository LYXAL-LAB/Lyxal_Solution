-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array.surql
-- Fonction : fn::validation_array
--
-- Valide qu'une valeur est un tableau.
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
--
-- Exemple (dans une fonction de module)
--   LET $tags = fn::validation_array($params.tags);
--   IF !$tags.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $tags.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur est un tableau. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
