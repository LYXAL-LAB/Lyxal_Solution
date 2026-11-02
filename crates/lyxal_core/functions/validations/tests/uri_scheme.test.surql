-- lyxal-test: assertions
-- Tests de fn::validation_uri_scheme (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_uri_scheme(" HTTPS ", ["https", "sftp"])
    == { valid: true, value: "https", code: NONE, details: {} };

-- test: schéma invalide
RETURN fn::validation_uri_scheme("1http", ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "uri_scheme" } };

-- test: schéma non autorisé
RETURN fn::validation_uri_scheme("ftp", ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["https", "sftp"] } };

-- test: chaîne blanche
RETURN fn::validation_uri_scheme("  ", ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_uri_scheme(NONE, ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_uri_scheme(NULL, ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_uri_scheme(42, ["https", "sftp"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_uri_scheme("https", []);

-- test: schéma autorisé invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_uri_scheme("https", ["ht tp"]);
