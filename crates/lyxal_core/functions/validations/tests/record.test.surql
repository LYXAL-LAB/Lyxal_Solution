-- lyxal-test: assertions
-- Tests de fn::validation_record (format : crates/lyxal_core/implementation_plan.md §5).

-- test: identifiant seul
RETURN fn::validation_record(" abc ", "booking_team")
    == { valid: true, value: booking_team:abc, code: NONE, details: {} };

-- test: table et identifiant
RETURN fn::validation_record("booking_team:abc", "booking_team")
    == { valid: true, value: booking_team:abc, code: NONE, details: {} };

-- test: autre table
RETURN fn::validation_record("identity_user:abc", "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["booking_team"] } };

-- test: identifiant vide
RETURN fn::validation_record("booking_team:", "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "record" } };

-- test: trop de séparateurs
RETURN fn::validation_record("a:b:c", "booking_team").code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_record("  ", "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_record(NONE, "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_record(NULL, "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type record refusé
RETURN fn::validation_record(booking_team:abc, "booking_team")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "record" } };

-- test: table attendue invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_record("abc", "booking-team");
