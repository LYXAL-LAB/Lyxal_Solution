-- lyxal-test: assertions
-- Tests de fn::validation_object_no_none (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_object_no_none({ a: 1, b: NULL })
    == { valid: true, value: { a: 1, b: NULL }, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_object_no_none(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_no_none(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object_no_none([])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: valeur NONE
RETURN fn::validation_object_no_none({ a: 1, b: NONE })
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "value", keys: ["b"] } };
