-- lyxal-test: assertions
-- Tests de fn::validation_number (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur dans les bornes
RETURN fn::validation_number(19.99dec, 0, 100)
    == { valid: true, value: 19.99dec, code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_number(19.99dec, NONE, NONE)
    == { valid: true, value: 19.99dec, code: NONE, details: {} };

-- test: borne minimale incluse
RETURN fn::validation_number(0, 0, 100)
    == { valid: true, value: 0, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_number(-1, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0 } };

-- test: trop grand
RETURN fn::validation_number(100.5f, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } };

-- test: valeur absente
RETURN fn::validation_number(NONE, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_number(NULL, 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_number("19.99", 0, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_number(19.99dec, 100, 0);
