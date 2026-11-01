-- lyxal-test: assertions
-- Tests de fn::validation_execution_timeout (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans les bornes
RETURN fn::validation_execution_timeout(30s, 1s, 15m)
    == { valid: true, value: 30s, code: NONE, details: {} };

-- test: trop court
RETURN fn::validation_execution_timeout(0s, 1s, 15m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1s } };

-- test: trop long
RETURN fn::validation_execution_timeout(1h, 1s, 15m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 15m } };

-- test: valeur absente
RETURN fn::validation_execution_timeout(NONE, 1s, 15m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_execution_timeout(NULL, 1s, 15m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_execution_timeout(30, 1s, 15m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: "int" } };

-- test: borne minimale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_execution_timeout(30s, 0s, 15m);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_execution_timeout(30s, 15m, 1s);
