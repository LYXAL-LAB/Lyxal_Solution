-- lyxal-test: assertions
-- Tests de fn::sanitize_timestamp (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: secondes
RETURN fn::sanitize_timestamp(d"2026-01-01T00:00:00Z", "seconds") == 1767225600;

-- test: millisecondes
RETURN fn::sanitize_timestamp(d"2026-01-01T00:00:00.5Z", "milliseconds") == 1767225600500;

-- test: unité inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_timestamp(d"2026-01-01T00:00:00Z", "days");

-- test: entrée absente → NONE
RETURN fn::sanitize_timestamp(NONE, "seconds") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_timestamp(NULL, "seconds");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_timestamp("2026", "seconds");
