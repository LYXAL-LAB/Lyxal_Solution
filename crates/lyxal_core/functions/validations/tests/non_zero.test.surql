-- lyxal-test: assertions
-- Tests de fn::validation_non_zero (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_non_zero(-2)
    == { valid: true, value: -2, code: NONE, details: {} };

-- test: valeur refusée
RETURN fn::validation_non_zero(0dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_ZERO", details: {} };

-- test: valeur absente
RETURN fn::validation_non_zero(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_non_zero(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_non_zero("1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };
