-- lyxal-test: assertions
-- Tests de fn::validation_time_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: intervalle valide
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", false, 1h, 24h)
    == { valid: true, value: { start_at: d"2026-08-03T00:00:00Z", end_at: d"2026-08-03T12:00:00Z", duration: 12h }, code: NONE, details: {} };

-- test: durée nulle autorisée
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T00:00:00Z", true, NONE, NONE)
    == { valid: true, value: { start_at: d"2026-08-03T00:00:00Z", end_at: d"2026-08-03T00:00:00Z", duration: 0ns }, code: NONE, details: {} };

-- test: durée nulle refusée
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T00:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: d"2026-08-03T00:00:00Z", end: d"2026-08-03T00:00:00Z", allow_equal: false } };

-- test: fin avant début
RETURN fn::validation_time_range(d"2026-08-03T12:00:00Z", d"2026-08-03T00:00:00Z", true, NONE, NONE).code == "CORE_VALIDATION_RANGE_ORDER";

-- test: trop court
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", false, 13h, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_duration: 13h, duration: 12h } };

-- test: trop long
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", false, NONE, 8h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_duration: 8h, duration: 12h } };

-- test: début absent
RETURN fn::validation_time_range(NONE, d"2026-08-03T12:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } };

-- test: fin de type entier
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", 3, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "datetime", actual: "int" } };

-- test: durées inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", false, 8h, 1h);

-- test: durée maximale nulle sans durée nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_time_range(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", false, NONE, 0ns);
