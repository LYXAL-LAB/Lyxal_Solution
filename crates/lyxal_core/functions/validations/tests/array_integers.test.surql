-- lyxal-test: assertions
-- Tests de fn::validation_array_integers (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entiers dans les bornes
RETURN fn::validation_array_integers([1, 5], 1, 10)
    == { valid: true, value: [1, 5], code: NONE, details: {} };

-- test: tableau vide accepté
RETURN fn::validation_array_integers([], 1, 10)
    == { valid: true, value: [], code: NONE, details: {} };

-- test: élément non entier
RETURN fn::validation_array_integers([1, 2.5f], NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "int" } };

-- test: élément trop petit
RETURN fn::validation_array_integers([0, 5], 1, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { scope: "item", min: 1 } };

-- test: élément trop grand
RETURN fn::validation_array_integers([5, 11], NONE, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { scope: "item", max: 10 } };

-- test: valeur absente
RETURN fn::validation_array_integers(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_integers(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_array_integers(5, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_integers([1], 10, 1);
