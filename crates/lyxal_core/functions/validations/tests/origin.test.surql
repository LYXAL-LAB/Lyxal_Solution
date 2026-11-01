-- lyxal-test: assertions
-- Tests de fn::validation_origin (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_origin(" https://App.example.com ", false, true, true)
    == { valid: true, value: "https://app.example.com", code: NONE, details: {} };

-- test: port refusé
RETURN fn::validation_origin("https://app.example.com:8443", false, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "port" } };

-- test: port autorisé
RETURN fn::validation_origin("https://app.example.com:8443", false, true, true)
    == { valid: true, value: "https://app.example.com:8443", code: NONE, details: {} };

-- test: avec chemin
RETURN fn::validation_origin("https://app.example.com/login", false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "origin" } };

-- test: schéma http refusé
RETURN fn::validation_origin("http://app.example.com", false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "scheme" } };

-- test: chaîne blanche
RETURN fn::validation_origin("  ", false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_origin(NONE, false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_origin(NULL, false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_origin(42, false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: aucun schéma
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_origin("https://a.b", false, false, true);
