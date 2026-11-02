-- lyxal-test: assertions
-- Tests de fn::validation_duration (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dans les bornes
RETURN fn::validation_duration(30s, 1s, 5m)
    == { valid: true, value: 30s, code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_duration(0ns, NONE, NONE)
    == { valid: true, value: 0ns, code: NONE, details: {} };

-- test: trop courte
RETURN fn::validation_duration(500ms, 1s, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1s } };

-- test: trop longue
RETURN fn::validation_duration(10m, NONE, 5m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 5m } };

-- test: valeur absente
RETURN fn::validation_duration(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_duration(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_duration("30s", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "duration", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_duration(30s, 5m, 1s);
