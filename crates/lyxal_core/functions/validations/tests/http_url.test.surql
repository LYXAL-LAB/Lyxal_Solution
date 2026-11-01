-- lyxal-test: assertions
-- Tests de fn::validation_http_url (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_http_url(" https://example.com/hook ", false, true)
    == { valid: true, value: "https://example.com/hook", code: NONE, details: {} };

-- test: schéma ftp
RETURN fn::validation_http_url("ftp://example.com/file", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "http_url" } };

-- test: http refusé
RETURN fn::validation_http_url("http://example.com", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "scheme" } };

-- test: chaîne blanche
RETURN fn::validation_http_url("  ", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_http_url(NONE, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_http_url(NULL, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_http_url(42, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: aucun schéma
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_http_url("https://a.b", false, false);
