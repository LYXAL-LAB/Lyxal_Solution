-- lyxal-test: assertions
-- Tests de fn::validation_surql_namespace (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_surql_namespace(" booking_slot ", 64)
    == { valid: true, value: "booking_slot", code: NONE, details: {} };

-- test: tiret refusé
RETURN fn::validation_surql_namespace("booking-slot", 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_identifier" } };

-- test: trop long
RETURN fn::validation_surql_namespace("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 64, length: 65 } };

-- test: chaîne blanche
RETURN fn::validation_surql_namespace("  ", 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_namespace(NONE, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_namespace(NULL, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_namespace(42, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_namespace("a", 0);
