-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_bucket_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_lyxal_bucket_name(" Tenant-Docs ", 3, 63)
    == { valid: true, value: "tenant-docs", code: NONE, details: {} };

-- test: adresse IP refusée
RETURN fn::validation_lyxal_bucket_name("10.0.0.1", 3, 63).code == "CORE_VALIDATION_FORMAT";

-- test: tiret doublé
RETURN fn::validation_lyxal_bucket_name("tenant--docs", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_bucket_name" } };

-- test: forme d'adresse IP
RETURN fn::validation_lyxal_bucket_name("192.168.1.1", 3, 63).code == "CORE_VALIDATION_FORMAT";

-- test: trop court
RETURN fn::validation_lyxal_bucket_name("ab", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 3, length: 2 } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_bucket_name("  ", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_bucket_name(NONE, 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_bucket_name(NULL, 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_bucket_name(42, 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur minimale trop faible
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_bucket_name("abc", 2, 10);
