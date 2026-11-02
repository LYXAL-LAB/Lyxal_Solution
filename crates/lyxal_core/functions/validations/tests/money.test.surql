-- lyxal-test: assertions
-- Tests de fn::validation_money (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: montant valide
RETURN fn::validation_money(19.99dec, 0dec, NONE, 2)
    == { valid: true, value: 19.99dec, code: NONE, details: {} };

-- test: entier en decimal
RETURN fn::validation_money(20dec, NONE, NONE, 0)
    == { valid: true, value: 20dec, code: NONE, details: {} };

-- test: trop de décimales
RETURN fn::validation_money(19.999dec, NONE, NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { max_scale: 2, scale: 3 } };

-- test: trop petit
RETURN fn::validation_money(-1dec, 0dec, NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0dec } };

-- test: trop grand
RETURN fn::validation_money(1000dec, NONE, 999.99dec, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 999.99dec } };

-- test: valeur absente
RETURN fn::validation_money(NONE, NONE, NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_money(NULL, NONE, NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_money(19.99f, NONE, NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "decimal", actual: "float" } };

-- test: échelle négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_money(1dec, NONE, NONE, -1);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_money(1dec, 10dec, 1dec, 2);
