-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/workflow_delay.surql
-- Fonction : fn::validation_workflow_delay
--
-- Valide un délai d'attente de workflow : durée comprise entre deux bornes
-- incluses, nulle seulement si autorisé.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_delay  : duration — délai minimal inclus
--   $max_delay  : duration — délai maximal inclus (>= $min_delay)
--   $allow_zero : bool — true pour accepter un délai de 0s
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la durée d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_ZERO
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_delay > $max_delay
--
-- Exemple (dans une fonction de module)
--   LET $delay = fn::validation_workflow_delay($params.delay, 0s, 7d, true);
--   IF !$delay.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $delay.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_workflow_delay(
    $value: any,
    $min_delay: duration,
    $max_delay: duration,
    $allow_zero: bool
) -> object {
    IF $min_delay > $max_delay { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_duration($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: type::of($value) } };
    };
    IF !$allow_zero AND $value = 0s { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_ZERO", details: {} }; };
    IF $min_delay IS NOT NONE AND $value < $min_delay { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_delay } }; };
    IF $max_delay IS NOT NONE AND $value > $max_delay { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_delay } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un délai de workflow borné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
