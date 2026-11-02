-- lyxal-test: assertions
-- Tests de fn::validation_hostname (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_hostname(" Web-01.Example.com ", false)
    == { valid: true, value: "web-01.example.com", code: NONE, details: {} };

-- test: label unique autorisé
RETURN fn::validation_hostname("localhost", true)
    == { valid: true, value: "localhost", code: NONE, details: {} };

-- test: label commençant par un tiret
RETURN fn::validation_hostname("-web.example.com", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hostname" } };

-- test: label trop long
RETURN fn::validation_hostname("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com", false).code == "CORE_VALIDATION_FORMAT";

-- test: label unique refusé
RETURN fn::validation_hostname("localhost", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "single_label" } };

-- test: chaîne blanche
RETURN fn::validation_hostname("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_hostname(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_hostname(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_hostname(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
