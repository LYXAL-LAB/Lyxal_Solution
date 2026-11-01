-- lyxal-test: assertions
-- Tests de fn::validation_object_non_empty (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_object_non_empty({ a: 1 })
    == { valid: true, value: { a: 1 }, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_object_non_empty(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_non_empty(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_object_non_empty("a")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "string" } };

-- test: objet vide
RETURN fn::validation_object_non_empty({})
    == { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: {} };
