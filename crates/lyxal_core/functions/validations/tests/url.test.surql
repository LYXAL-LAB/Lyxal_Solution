-- lyxal-test: assertions
-- Tests de fn::validation_url (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_url(" https://example.com/a?b=1 ", 2048)
    == { valid: true, value: "https://example.com/a?b=1", code: NONE, details: {} };

-- test: trop longue
RETURN fn::validation_url("https://example.com", 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 10, length: 19 } };

-- test: URL relative
RETURN fn::validation_url("/a/b", 2048)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "url" } };

-- test: chaîne blanche
RETURN fn::validation_url("  ", 2048)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_url(NONE, 2048)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_url(NULL, 2048)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_url(42, 2048)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_url("https://a.b", 0);
