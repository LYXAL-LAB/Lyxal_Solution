-- lyxal-test: assertions
-- Tests de fn::validation_surql_record_string (format : crates/lyxal_core/Readme.md, section « Tests »).

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

-- test: texte après l'identifiant refusé (ignoré par type::record)
RETURN fn::validation_surql_record_string("identity_user:abc xyz", "identity_user")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };

-- test: texte après un identifiant composé refusé
RETURN fn::validation_surql_record_string("scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z'] trailing", "scheduler_run")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };

-- test: écriture non canonique d'un identifiant composé refusée
RETURN fn::validation_surql_record_string("scheduler_run:[scheduler_schedule:x,d'2026-01-01T00:00:00Z']", "scheduler_run")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };

-- test: identifiant composé sous sa forme canonique accepté
RETURN fn::validation_surql_record_string("scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z']", "scheduler_run")
    == { valid: true, value: "scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z']", code: NONE, details: {} };

-- test: table invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_record_string("a:b", "a-b");
