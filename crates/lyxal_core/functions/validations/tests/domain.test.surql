-- lyxal-test: assertions
-- Tests de fn::validation_domain (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_domain(" Api.Example.COM ", true)
    == { valid: true, value: "api.example.com", code: NONE, details: {} };

-- test: sous-domaine refusé
RETURN fn::validation_domain("api.example.com", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "subdomain" } };

-- test: domaine racine accepté
RETURN fn::validation_domain("example.com", false)
    == { valid: true, value: "example.com", code: NONE, details: {} };

-- test: domaine invalide
RETURN fn::validation_domain("exa mple.com", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "domain" } };

-- test: chaîne blanche
RETURN fn::validation_domain("  ", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_domain(NONE, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_domain(NULL, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_domain(42, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
