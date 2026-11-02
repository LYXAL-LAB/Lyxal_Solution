-- lyxal-test: assertions
-- Tests de fn::validation_array_without_none (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_array_without_none([1, NULL])
    == { valid: true, value: [1, NULL], code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_array_without_none(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_without_none(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_array_without_none("a")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "string" } };

-- test: élément NONE
RETURN fn::validation_array_without_none([1, NONE])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "item" } };
