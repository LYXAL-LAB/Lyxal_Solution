-- lyxal-test: assertions
-- Tests de fn::validation_min_length (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: longueur suffisante, espaces conservés
RETURN fn::validation_min_length(" abc", 4)
    == { valid: true, value: " abc", code: NONE, details: {} };

-- test: trop courte
RETURN fn::validation_min_length("abc", 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 4, length: 3 } };

-- test: valeur absente
RETURN fn::validation_min_length(NONE, 1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_min_length(NULL, 1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_min_length(1234, 1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_min_length("abc", -1);
