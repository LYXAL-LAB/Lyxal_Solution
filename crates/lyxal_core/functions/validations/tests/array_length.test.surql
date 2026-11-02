-- lyxal-test: assertions
-- Tests de fn::validation_array_length (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: longueur dans les bornes
RETURN fn::validation_array_length([1, 2], 1, 3)
    == { valid: true, value: [1, 2], code: NONE, details: {} };

-- test: trop court
RETURN fn::validation_array_length([], 1, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 1, length: 0 } };

-- test: trop long
RETURN fn::validation_array_length([1, 2, 3], NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 2, length: 3 } };

-- test: valeur absente
RETURN fn::validation_array_length(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_length(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_array_length("ab", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "string" } };

-- test: borne négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_length([], -1, NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_length([], 3, 1);
