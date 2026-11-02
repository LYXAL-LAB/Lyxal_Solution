-- lyxal-test: assertions
-- Tests de fn::validation_array_without_null (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_array_without_null([1, 2])
    == { valid: true, value: [1, 2], code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_array_without_null(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_without_null(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_array_without_null("a")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "string" } };

-- test: élément NULL
RETURN fn::validation_array_without_null([1, NULL])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { scope: "item" } };
