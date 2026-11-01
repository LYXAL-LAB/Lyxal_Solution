-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/execution_timeout.surql
-- Fonction : fn::validation_execution_timeout
--
-- Valide un délai d'expiration d'exécution : durée strictement positive
-- comprise entre deux bornes incluses.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $min_timeout : duration — délai minimal inclus (> 0s)
--   $max_timeout : duration — délai maximal inclus (>= $min_timeout)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la durée d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne <= 0s ou $min_timeout > $max_timeout
--
-- Exemple (dans une fonction de module)
--   LET $timeout = fn::validation_execution_timeout($params.timeout, 1s, 15m);
--   IF !$timeout.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $timeout.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_execution_timeout(
    $value: any,
    $min_timeout: duration,
    $max_timeout: duration
) -> object {
    IF $min_timeout <= 0s OR $min_timeout > $max_timeout { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_duration($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: type::of($value) } };
    };
    IF $min_timeout IS NOT NONE AND $value < $min_timeout { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_timeout } }; };
    IF $max_timeout IS NOT NONE AND $value > $max_timeout { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_timeout } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un délai d'expiration positif et borné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
