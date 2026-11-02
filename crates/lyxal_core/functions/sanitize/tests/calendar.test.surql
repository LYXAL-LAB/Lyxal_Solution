-- lyxal-test: assertions
-- Tests de fn::sanitize_calendar (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: début du mois
RETURN fn::sanitize_calendar(d"2026-08-03T12:34:56.789Z", "month") == d"2026-08-01T00:00:00Z";

-- test: unité insensible à la casse
RETURN fn::sanitize_calendar(d"2026-08-03T12:34:56.789Z", " HOUR ") == d"2026-08-03T12:00:00Z";

-- test: unité inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_calendar(d"2026-08-03T12:34:56.789Z", "week");

-- test: entrée absente → NONE
RETURN fn::sanitize_calendar(NONE, "month") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_calendar(NULL, "month");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_calendar("2026-08-03", "month");
