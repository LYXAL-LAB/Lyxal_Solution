-- lyxal-test: assertions
-- Tests de fn::validation_datetime (format : crates/lyxal_core/implementation_plan.md §5).

-- test: instant dans les bornes
RETURN fn::validation_datetime(d"2026-08-03T12:00:00Z", d"2026-08-03T00:00:00Z", d"2026-08-31T00:00:00Z")
    == { valid: true, value: d"2026-08-03T12:00:00Z", code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_datetime(d"2026-08-03T12:00:00Z", NONE, NONE)
    == { valid: true, value: d"2026-08-03T12:00:00Z", code: NONE, details: {} };

-- test: trop tôt
RETURN fn::validation_datetime(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: d"2026-08-03T12:00:00Z" } };

-- test: trop tard
RETURN fn::validation_datetime(d"2026-08-03T12:00:00Z", NONE, d"2026-08-03T00:00:00Z")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: d"2026-08-03T00:00:00Z" } };

-- test: valeur absente
RETURN fn::validation_datetime(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_datetime(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_datetime("2026-08-03T12:00:00Z", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "string" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_datetime(d"2026-08-03T12:00:00Z", d"2026-08-03T12:00:00Z", d"2026-08-03T00:00:00Z");
