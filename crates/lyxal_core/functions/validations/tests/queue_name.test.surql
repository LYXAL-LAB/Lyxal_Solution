-- lyxal-test: assertions
-- Tests de fn::validation_queue_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_queue_name(" Mail-Outbox ", 3, 30)
    == { valid: true, value: "mail-outbox", code: NONE, details: {} };

-- test: souligné refusé
RETURN fn::validation_queue_name("mail_outbox", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "kebab_case" } };

-- test: tiret final
RETURN fn::validation_queue_name("mail-", 3, 30).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_queue_name("  ", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_queue_name(NONE, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_queue_name(NULL, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_queue_name(42, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_queue_name("abc", 5, 3);
