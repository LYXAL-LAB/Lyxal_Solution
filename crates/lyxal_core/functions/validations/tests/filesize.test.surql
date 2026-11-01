-- lyxal-test: assertions
-- Tests de fn::validation_filesize (format : crates/lyxal_core/implementation_plan.md §5).

-- test: taille dans les bornes
RETURN fn::validation_filesize(2048, 1, 4096)
    == { valid: true, value: 2048, code: NONE, details: {} };

-- test: taille nulle sans minimum
RETURN fn::validation_filesize(0, NONE, NONE)
    == { valid: true, value: 0, code: NONE, details: {} };

-- test: taille négative
RETURN fn::validation_filesize(-1, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0 } };

-- test: trop grande
RETURN fn::validation_filesize(5000, NONE, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 4096 } };

-- test: valeur absente
RETURN fn::validation_filesize(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_filesize(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_filesize(1.5f, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "float" } };

-- test: borne négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_filesize(1, -1, NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_filesize(1, 10, 5);
