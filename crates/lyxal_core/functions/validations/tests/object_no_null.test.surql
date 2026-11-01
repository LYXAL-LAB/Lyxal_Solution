-- lyxal-test: assertions
-- Tests de fn::validation_object_no_null (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_object_no_null({ a: 1 })
    == { valid: true, value: { a: 1 }, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_object_no_null(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_no_null(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object_no_null([])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: valeur NULL
RETURN fn::validation_object_no_null({ a: NULL, b: 1 })
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { scope: "value", keys: ["a"] } };
