-- lyxal-test: assertions
-- Tests de fn::validation_lowercase (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme nettoyée
RETURN fn::validation_lowercase(" " + "hello-123" + " ", true, false)
    == { valid: true, value: "hello-123", code: NONE, details: {} };

-- test: valeur non conforme
RETURN fn::validation_lowercase("Hello", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lowercase" } };

-- test: vide autorisée
RETURN fn::validation_lowercase("  ", true, true)
    == { valid: true, value: "", code: NONE, details: {} };

-- test: vide refusée
RETURN fn::validation_lowercase("  ", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lowercase(NONE, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lowercase(NULL, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lowercase(1, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
