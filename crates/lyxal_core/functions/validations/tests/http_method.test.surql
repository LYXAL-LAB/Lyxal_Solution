-- lyxal-test: assertions
-- Tests de fn::validation_http_method (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_http_method(" post ", ["GET", "post"])
    == { valid: true, value: "POST", code: NONE, details: {} };

-- test: caractère interdit
RETURN fn::validation_http_method("GET2", ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "http_method" } };

-- test: méthode non autorisée
RETURN fn::validation_http_method("DELETE", ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["GET", "POST"] } };

-- test: chaîne blanche
RETURN fn::validation_http_method("  ", ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_http_method(NONE, ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_http_method(NULL, ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_http_method(42, ["GET", "post"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_http_method("GET", []);
