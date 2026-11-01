-- lyxal-test: assertions
-- Tests de fn::validation_workflow_delay (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans les bornes
RETURN fn::validation_workflow_delay(1h, 0s, 7d, true)
    == { valid: true, value: 1h, code: NONE, details: {} };

-- test: zéro autorisé
RETURN fn::validation_workflow_delay(0s, 0s, 7d, true)
    == { valid: true, value: 0s, code: NONE, details: {} };

-- test: zéro refusé
RETURN fn::validation_workflow_delay(0s, 0s, 7d, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_ZERO", details: {} };

-- test: trop court
RETURN fn::validation_workflow_delay(30s, 1m, 7d, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1m } };

-- test: trop long
RETURN fn::validation_workflow_delay(8d, 0s, 7d, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 7d } };

-- test: valeur absente
RETURN fn::validation_workflow_delay(NONE, 0s, 7d, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_workflow_delay(NULL, 0s, 7d, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_workflow_delay("1h", 0s, 7d, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_workflow_delay(1h, 7d, 0s, true);
