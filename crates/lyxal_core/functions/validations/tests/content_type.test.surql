-- lyxal-test: assertions
-- Tests de fn::validation_content_type (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_content_type(" Application/JSON; charset=UTF-8 ", ["application/json"])
    == { valid: true, value: "application/json; charset=utf-8", code: NONE, details: {} };

-- test: sans sous-type
RETURN fn::validation_content_type("application", ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "content_type" } };

-- test: type non autorisé
RETURN fn::validation_content_type("text/html", ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["application/json"] } };

-- test: chaîne blanche
RETURN fn::validation_content_type("  ", ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_content_type(NONE, ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_content_type(NULL, ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_content_type(42, ["application/json"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_content_type("text/html", []);
