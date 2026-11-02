-- lyxal-test: assertions
-- Tests de fn::validation_object (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_object({ a: 1 })
    == { valid: true, value: { a: 1 }, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_object(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object([1])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: objet vide accepté
RETURN fn::validation_object({})
    == { valid: true, value: {}, code: NONE, details: {} };
