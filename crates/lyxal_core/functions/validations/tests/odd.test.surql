-- lyxal-test: assertions
-- Tests de fn::validation_odd (format : crates/lyxal_core/implementation_plan.md §5).

-- test: entier impair
RETURN fn::validation_odd(-3)
    == { valid: true, value: -3, code: NONE, details: {} };

-- test: entier pair
RETURN fn::validation_odd(0)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_PARITY", details: { expected: "odd" } };

-- test: valeur absente
RETURN fn::validation_odd(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_odd(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type decimal refusé
RETURN fn::validation_odd(3dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "decimal" } };
