-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_event_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_event_name(" Booking.Created ", 2, 3)
    == { valid: true, value: "booking.created", code: NONE, details: {} };

-- test: un seul segment
RETURN fn::validation_lyxal_event_name("booking", 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_segments: 2, segments: 1 } };

-- test: trop de segments
RETURN fn::validation_lyxal_event_name("a.b.c.d", 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: 3, segments: 4 } };

-- test: point final
RETURN fn::validation_lyxal_event_name("booking.", 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_event_name" } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_event_name("  ", 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_event_name(NONE, 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_event_name(NULL, 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_event_name(42, 2, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: segments inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_event_name("a.b", 3, 2);
