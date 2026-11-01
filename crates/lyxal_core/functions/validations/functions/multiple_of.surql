-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/multiple_of.surql
-- Fonction : fn::validation_multiple_of
--
-- Valide qu'une valeur est un entier multiple d'un diviseur donné.
--
-- Paramètres
--   $value   : any — valeur à contrôler
--   $divisor : int — diviseur, différent de 0
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'entier d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_MULTIPLE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $divisor = 0
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_multiple_of($params.minutes, 15);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_multiple_of(
    $value: any,
    $divisor: int
) -> object {
    IF $divisor = 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value % $divisor != 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_MULTIPLE", details: { divisor: $divisor } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un entier est multiple du diviseur. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
