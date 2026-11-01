-- lyxal-test: assertions
-- Tests de fn::validation_iso8601 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme nettoyée
RETURN fn::validation_iso8601(" 2026-08-03T14:30:00+02:00 ", false)
    == { valid: true, value: "2026-08-03T14:30:00+02:00", code: NONE, details: {} };

-- test: sans fuseau
RETURN fn::validation_iso8601("2026-08-03T14:30:00", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iso8601" } };

-- test: fractions refusées
RETURN fn::validation_iso8601("2026-08-03T14:30:00.123Z", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iso8601" } };

-- test: mois impossible
RETURN fn::validation_iso8601("2026-13-03T14:30:00Z", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iso8601" } };

-- test: chaîne blanche
RETURN fn::validation_iso8601("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_iso8601(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_iso8601(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_iso8601(1, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: fractions autorisées
RETURN fn::validation_iso8601("2026-08-03T14:30:00.123Z", true)
    == { valid: true, value: "2026-08-03T14:30:00.123Z", code: NONE, details: {} };
