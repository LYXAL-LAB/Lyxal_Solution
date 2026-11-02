-- lyxal-test: assertions
-- Tests de fn::validation_base64 (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: Base64 standard
RETURN fn::validation_base64(" YWJj ", false, true)
    == { valid: true, value: "YWJj", code: NONE, details: {} };

-- test: Base64 URL-safe
RETURN fn::validation_base64("a-_b", true, true)
    == { valid: true, value: "a-_b", code: NONE, details: {} };

-- test: caractère URL-safe refusé en standard
RETURN fn::validation_base64("a-_b", false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "base64" } };

-- test: remplissage exigé
RETURN fn::validation_base64("YWJjZA", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "base64_padding" } };

-- test: remplissage facultatif
RETURN fn::validation_base64("YWJjZA", false, false)
    == { valid: true, value: "YWJjZA", code: NONE, details: {} };

-- test: chaîne blanche
RETURN fn::validation_base64("  ", false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_base64(NONE, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_base64(NULL, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_base64(1, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
