-- lyxal-test: assertions
-- Tests de fn::validation_surql_record_string (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_surql_record_string(" identity_user:abc ", "identity_user")
    == { valid: true, value: "identity_user:abc", code: NONE, details: {} };

-- test: toutes tables
RETURN fn::validation_surql_record_string("team:x", NONE)
    == { valid: true, value: "team:x", code: NONE, details: {} };

-- test: autre table
RETURN fn::validation_surql_record_string("booking_team:abc", "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["identity_user"] } };

-- test: sans identifiant
RETURN fn::validation_surql_record_string("identity_user", "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };

-- test: chaîne blanche
RETURN fn::validation_surql_record_string("  ", "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_record_string(NONE, "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_record_string(NULL, "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_record_string(42, "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: table invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_record_string("a:b", "a-b");
