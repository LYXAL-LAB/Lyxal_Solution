-- lyxal-test: assertions
-- Tests de fn::sanitize_schedule (format : crates/lyxal_core/implementation_plan.md §5).

-- test: début arrondi
RETURN fn::sanitize_schedule(d"2026-08-03T10:07:30Z", 1h, 15m) == { start_at: d"2026-08-03T10:00:00Z", end_at: d"2026-08-03T11:00:00Z", duration: 1h };

-- test: précision nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_schedule(d"2026-08-03T10:00:00Z", 1h, 0ns);

-- test: entrée absente → NONE
RETURN fn::sanitize_schedule(NONE, 1h, 15m) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_schedule(NULL, 1h, 15m);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_schedule("2026-08-03", 1h, 15m);
