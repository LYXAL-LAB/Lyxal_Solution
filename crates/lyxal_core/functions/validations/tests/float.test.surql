-- lyxal-test: assertions
-- Tests de fn::validation_float (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur dans les bornes
RETURN fn::validation_float(1.5f, 0f, 10f)
    == { valid: true, value: 1.5f, code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_float(1.5f, NONE, NONE)
    == { valid: true, value: 1.5f, code: NONE, details: {} };

-- test: borne minimale incluse
RETURN fn::validation_float(0f, 0f, 10f)
    == { valid: true, value: 0f, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_float(-0.5f, 0f, 10f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0f } };

-- test: trop grand
RETURN fn::validation_float(10.5f, 0f, 10f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 10f } };

-- test: valeur absente
RETURN fn::validation_float(NONE, 0f, 10f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_float(NULL, 0f, 10f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type decimal refusé
RETURN fn::validation_float(1dec, 0f, 10f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "float", actual: "decimal" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_float(1.5f, 10f, 0f);
