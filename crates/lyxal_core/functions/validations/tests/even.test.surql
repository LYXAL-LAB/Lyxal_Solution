-- lyxal-test: assertions
-- Tests de fn::validation_even (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entier pair
RETURN fn::validation_even(-4)
    == { valid: true, value: -4, code: NONE, details: {} };

-- test: entier impair
RETURN fn::validation_even(3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_PARITY", details: { expected: "even" } };

-- test: valeur absente
RETURN fn::validation_even(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_even(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_even(2f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "float" } };
