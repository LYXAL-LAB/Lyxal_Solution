-- lyxal-test: assertions
-- Tests de fn::validation_decimal (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur dans les bornes
RETURN fn::validation_decimal(19.99dec, 0dec, 100dec)
    == { valid: true, value: 19.99dec, code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_decimal(19.99dec, NONE, NONE)
    == { valid: true, value: 19.99dec, code: NONE, details: {} };

-- test: borne minimale incluse
RETURN fn::validation_decimal(0dec, 0dec, 100dec)
    == { valid: true, value: 0dec, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_decimal(-0.01dec, 0dec, 100dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0dec } };

-- test: trop grand
RETURN fn::validation_decimal(100.01dec, 0dec, 100dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100dec } };

-- test: valeur absente
RETURN fn::validation_decimal(NONE, 0dec, 100dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_decimal(NULL, 0dec, 100dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_decimal(19.99f, 0dec, 100dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "decimal", actual: "float" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_decimal(19.99dec, 100dec, 0dec);
