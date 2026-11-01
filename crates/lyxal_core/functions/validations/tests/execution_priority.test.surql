-- lyxal-test: assertions
-- Tests de fn::validation_execution_priority (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans les bornes
RETURN fn::validation_execution_priority(5, 0, 10)
    == { valid: true, value: 5, code: NONE, details: {} };

-- test: trop basse
RETURN fn::validation_execution_priority(-1, 0, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0 } };

-- test: trop haute
RETURN fn::validation_execution_priority(11, 0, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 10 } };

-- test: valeur absente
RETURN fn::validation_execution_priority(NONE, 0, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_execution_priority(NULL, 0, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_execution_priority("5", 0, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_execution_priority(5, 10, 0);
