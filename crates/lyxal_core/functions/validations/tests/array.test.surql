-- lyxal-test: assertions
-- Tests de fn::validation_array (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_array([1, "a"])
    == { valid: true, value: [1, "a"], code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_array(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type object refusé
RETURN fn::validation_array({ a: 1 })
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "object" } };

-- test: tableau vide accepté
RETURN fn::validation_array([])
    == { valid: true, value: [], code: NONE, details: {} };
