-- lyxal-test: assertions
-- Tests de fn::validation_etag (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_etag(" \"33a64df5\" ", false)
    == { valid: true, value: "\"33a64df5\"", code: NONE, details: {} };

-- test: ETag faible autorisé
RETURN fn::validation_etag("W/\"33a64df5\"", true)
    == { valid: true, value: "W/\"33a64df5\"", code: NONE, details: {} };

-- test: sans guillemets
RETURN fn::validation_etag("33a64df5", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "etag" } };

-- test: ETag faible refusé
RETURN fn::validation_etag("W/\"33a64df5\"", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "weak" } };

-- test: chaîne blanche
RETURN fn::validation_etag("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_etag(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_etag(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_etag(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
