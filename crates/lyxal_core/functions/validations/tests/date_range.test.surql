-- lyxal-test: assertions
-- Tests de fn::validation_date_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: intervalle valide
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-08T00:00:00Z", false, 1, 30)
    == { valid: true, value: { start_date: d"2026-08-03T00:00:00Z", end_date: d"2026-08-08T00:00:00Z", days: 5 }, code: NONE, details: {} };

-- test: même jour autorisé
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-03T00:00:00Z", true, NONE, NONE)
    == { valid: true, value: { start_date: d"2026-08-03T00:00:00Z", end_date: d"2026-08-03T00:00:00Z", days: 0 }, code: NONE, details: {} };

-- test: même jour refusé
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-03T00:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: d"2026-08-03T00:00:00Z", end: d"2026-08-03T00:00:00Z", allow_equal: false } };

-- test: fin avant début
RETURN fn::validation_date_range(d"2026-08-08T00:00:00Z", d"2026-08-03T00:00:00Z", true, NONE, NONE).code == "CORE_VALIDATION_RANGE_ORDER";

-- test: trop court
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-08T00:00:00Z", false, 7, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_days: 7, days: 5 } };

-- test: trop long
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-08T00:00:00Z", false, NONE, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_days: 3, days: 5 } };

-- test: début absent
RETURN fn::validation_date_range(NONE, d"2026-08-08T00:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } };

-- test: fin NULL
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", NULL, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "end" } };

-- test: fin de type chaîne
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", "2026-08-08", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "datetime", actual: "string" } };

-- test: début avec heure
RETURN fn::validation_date_range(d"2026-08-03T12:00:00Z", d"2026-08-08T00:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "start", expected: "date" } };

-- test: jours négatifs
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-08T00:00:00Z", false, -1, NONE);

-- test: jours inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_date_range(d"2026-08-03T00:00:00Z", d"2026-08-08T00:00:00Z", false, 5, 2);
