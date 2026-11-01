-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/retry_policy.surql
-- Fonction : fn::validation_retry_policy
--
-- Valide une politique de nouvelle tentative { max_attempts, strategy,
-- initial_delay, max_delay? } et la renvoie normalisée (strategy en
-- minuscules, max_delay = initial_delay par défaut).
--
-- Paramètres
--   $value              : any — valeur à contrôler
--   $max_attempts_limit : int — nombre maximal de tentatives autorisé (>= 1)
--   $max_backoff        : duration — délai maximal autorisé
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { max_attempts, strategy, initial_delay, max_delay }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_RANGE_ORDER
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_attempts_limit < 1
--
-- Exemple (dans une fonction de module)
--   LET $policy = fn::validation_retry_policy($params.retry, 10, 1h);
--   IF !$policy.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $policy.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_retry_policy(
    $value: any,
    $max_attempts_limit: int,
    $max_backoff: duration
) -> object {
    IF $max_attempts_limit < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    LET $missing = array::filter(["max_attempts", "strategy", "initial_delay"], |$key| $value[$key] IS NONE);
    IF array::len($missing) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "key", keys: $missing } }; };
    IF !type::is_int($value.max_attempts) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { key: "max_attempts", expected: "int", actual: type::of($value.max_attempts) } }; };
    IF $value.max_attempts < 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { key: "max_attempts", min: 1 } }; };
    IF $value.max_attempts > $max_attempts_limit { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { key: "max_attempts", max: $max_attempts_limit } }; };
    IF !type::is_string($value.strategy) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { key: "strategy", expected: "string", actual: type::of($value.strategy) } }; };
    LET $strategy = string::lowercase(string::trim($value.strategy));
    IF $strategy NOT IN ["fixed", "linear", "exponential"] { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { key: "strategy", allowed: ["fixed", "linear", "exponential"] } }; };
    LET $max_delay = $value.max_delay ?? $value.initial_delay;
    IF !type::is_duration($value.initial_delay) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { key: "initial_delay", expected: "duration", actual: type::of($value.initial_delay) } }; };
    IF $value.initial_delay > $max_backoff { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { key: "initial_delay", max: $max_backoff } }; };
    IF !type::is_duration($max_delay) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { key: "max_delay", expected: "duration", actual: type::of($max_delay) } }; };
    IF $max_delay > $max_backoff { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { key: "max_delay", max: $max_backoff } }; };
    IF $max_delay < $value.initial_delay { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { initial_delay: $value.initial_delay, max_delay: $max_delay } }; };
    RETURN { valid: true, value: { max_attempts: $value.max_attempts, strategy: $strategy, initial_delay: $value.initial_delay, max_delay: $max_delay }, code: NONE, details: {} };
}
COMMENT "Valide et normalise une politique de nouvelle tentative. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
