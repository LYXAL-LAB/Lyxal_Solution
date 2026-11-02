-- lyxal-test: assertions
-- Tests de fn::validation_retry_policy (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: politique complète
RETURN fn::validation_retry_policy({ max_attempts: 3, strategy: " Exponential ", initial_delay: 1s, max_delay: 30s }, 10, 1h)
    == { valid: true, value: { max_attempts: 3, strategy: "exponential", initial_delay: 1s, max_delay: 30s }, code: NONE, details: {} };

-- test: max_delay par défaut
RETURN fn::validation_retry_policy({ max_attempts: 1, strategy: "fixed", initial_delay: 5s }, 10, 1h)
    == { valid: true, value: { max_attempts: 1, strategy: "fixed", initial_delay: 5s, max_delay: 5s }, code: NONE, details: {} };

-- test: clé manquante
RETURN fn::validation_retry_policy({ max_attempts: 3 }, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "key", keys: ["strategy", "initial_delay"] } };

-- test: trop de tentatives
RETURN fn::validation_retry_policy({ max_attempts: 20, strategy: "fixed", initial_delay: 1s }, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { key: "max_attempts", max: 10 } };

-- test: stratégie inconnue
RETURN fn::validation_retry_policy({ max_attempts: 3, strategy: "random", initial_delay: 1s }, 10, 1h).code == "CORE_VALIDATION_NOT_ALLOWED";

-- test: délai de type chaîne
RETURN fn::validation_retry_policy({ max_attempts: 3, strategy: "fixed", initial_delay: "1s" }, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { key: "initial_delay", expected: "duration", actual: "string" } };

-- test: délai trop long
RETURN fn::validation_retry_policy({ max_attempts: 3, strategy: "fixed", initial_delay: 2h }, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { key: "initial_delay", max: 1h } };

-- test: délais inversés
RETURN fn::validation_retry_policy({ max_attempts: 3, strategy: "linear", initial_delay: 10s, max_delay: 1s }, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { initial_delay: 10s, max_delay: 1s } };

-- test: valeur absente
RETURN fn::validation_retry_policy(NONE, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_retry_policy(NULL, 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_retry_policy([], 10, 1h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: limite nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_retry_policy({}, 0, 1h);
