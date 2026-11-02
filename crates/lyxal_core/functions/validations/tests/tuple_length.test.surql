-- lyxal-test: assertions
-- Tests de fn::validation_tuple_length (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: longueur exacte
RETURN fn::validation_tuple_length([1.5f, 2.5f], 2)
    == { valid: true, value: [1.5f, 2.5f], code: NONE, details: {} };

-- test: trop court
RETURN fn::validation_tuple_length([1], 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 2, length: 1 } };

-- test: trop long
RETURN fn::validation_tuple_length([1, 2, 3], 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 2, length: 3 } };

-- test: valeur absente
RETURN fn::validation_tuple_length(NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_tuple_length(NULL, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type object refusé
RETURN fn::validation_tuple_length({}, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "object" } };

-- test: longueur négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_tuple_length([], -1);
