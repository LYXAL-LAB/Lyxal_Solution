-- lyxal-test: assertions
-- Tests de fn::validation_email (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_email(" contact@example.com ", 254)
    == { valid: true, value: "contact@example.com", code: NONE, details: {} };

-- test: trop longue
RETURN fn::validation_email("contact@example.com", 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 10, length: 19 } };

-- test: sans longueur maximale
RETURN fn::validation_email("a@example.com", NONE)
    == { valid: true, value: "a@example.com", code: NONE, details: {} };

-- test: sans arobase
RETURN fn::validation_email("contact.example.com", 254)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "email" } };

-- test: chaîne blanche
RETURN fn::validation_email("  ", 254)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_email(NONE, 254)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_email(NULL, 254)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_email(42, 254)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_email("a@b.c", 0);
