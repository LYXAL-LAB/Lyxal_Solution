-- lyxal-test: assertions
-- Tests de fn::validation_max_length (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: longueur respectée
RETURN fn::validation_max_length("abc", 3)
    == { valid: true, value: "abc", code: NONE, details: {} };

-- test: trop longue
RETURN fn::validation_max_length("abcd", 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 3, length: 4 } };

-- test: valeur absente
RETURN fn::validation_max_length(NONE, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_max_length(NULL, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_max_length(12, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_max_length("abc", -1);
