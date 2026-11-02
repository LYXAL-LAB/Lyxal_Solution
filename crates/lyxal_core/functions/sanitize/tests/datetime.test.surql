-- lyxal-test: assertions
-- Tests de fn::sanitize_datetime (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: à la minute
RETURN fn::sanitize_datetime(d"2026-08-03T12:34:56.789Z", 1m) == d"2026-08-03T12:34:00Z";

-- test: précision nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_datetime(d"2026-08-03T12:34:56.789Z", 0ns);

-- test: entrée absente → NONE
RETURN fn::sanitize_datetime(NONE, 1m) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_datetime(NULL, 1m);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_datetime("2026-08-03", 1m);
