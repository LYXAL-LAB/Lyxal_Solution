-- lyxal-test: assertions
-- Tests de fn::validation_array_non_empty (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_array_non_empty([0])
    == { valid: true, value: [0], code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_array_non_empty(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_non_empty(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_array_non_empty("abc")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "string" } };

-- test: tableau vide
RETURN fn::validation_array_non_empty([])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: {} };
