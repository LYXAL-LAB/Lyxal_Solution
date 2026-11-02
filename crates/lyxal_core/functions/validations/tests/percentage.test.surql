-- lyxal-test: assertions
-- Tests de fn::validation_percentage (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dans les bornes
RETURN fn::validation_percentage(12.5f, 0, 100)
    == { valid: true, value: 12.5f, code: NONE, details: {} };

-- test: bornes 0 à 1
RETURN fn::validation_percentage(1, 0, 1)
    == { valid: true, value: 1, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_percentage(-1, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0 } };

-- test: trop grand
RETURN fn::validation_percentage(101, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } };

-- test: valeur absente
RETURN fn::validation_percentage(NONE, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_percentage(NULL, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_percentage("50", 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_percentage(50, 100, 0);
