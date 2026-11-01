-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/non_zero.surql
-- Fonction : fn::validation_non_zero
--
-- Valide qu'une valeur numérique est différente de zéro.
--
-- Paramètres
--   $value : any — valeur à contrôler (int, float ou decimal)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_ZERO
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_non_zero($params.amount);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_non_zero(
    $value: any
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_number($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: type::of($value) } };
    };
    IF $value = 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_ZERO", details: {} }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un nombre est différent de zéro. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
