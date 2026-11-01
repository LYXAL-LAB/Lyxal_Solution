-- lyxal-test: assertions
-- Tests de fn::validation_multiple_of (format : crates/lyxal_core/implementation_plan.md §5).

-- test: multiple
RETURN fn::validation_multiple_of(45, 15)
    == { valid: true, value: 45, code: NONE, details: {} };

-- test: non multiple
RETURN fn::validation_multiple_of(50, 15)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_MULTIPLE", details: { divisor: 15 } };

-- test: valeur absente
RETURN fn::validation_multiple_of(NONE, 15)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_multiple_of(NULL, 15)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_multiple_of(45f, 15)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "float" } };

-- test: diviseur nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_multiple_of(45, 0);
