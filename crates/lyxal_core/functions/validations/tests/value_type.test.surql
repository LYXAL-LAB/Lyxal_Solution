-- lyxal-test: assertions
-- Tests de fn::validation_value_type (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: type attendu
RETURN fn::validation_value_type({ a: 1 }, "object")
    == { valid: true, value: { a: 1 }, code: NONE, details: {} };

-- test: type attendu insensible à la casse
RETURN fn::validation_value_type("x", " String ")
    == { valid: true, value: "x", code: NONE, details: {} };

-- test: autre type
RETURN fn::validation_value_type(1, "string")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: valeur absente
RETURN fn::validation_value_type(NONE, "string")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_value_type(NULL, "string")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type attendu vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_value_type(1, "  ");
