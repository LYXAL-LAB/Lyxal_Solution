-- lyxal-test: assertions
-- Tests de fn::validation_mime_type (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_mime_type(" IMAGE/PNG ", ["image/png"])
    == { valid: true, value: "image/png", code: NONE, details: {} };

-- test: paramètre refusé
RETURN fn::validation_mime_type("image/png; q=1", ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "mime_type" } };

-- test: type non autorisé
RETURN fn::validation_mime_type("image/gif", ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["image/png"] } };

-- test: chaîne blanche
RETURN fn::validation_mime_type("  ", ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_mime_type(NONE, ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_mime_type(NULL, ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_mime_type(42, ["image/png"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_mime_type("image/png", []);
