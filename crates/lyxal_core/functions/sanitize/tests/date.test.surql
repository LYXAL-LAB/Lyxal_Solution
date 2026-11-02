-- lyxal-test: assertions
-- Tests de fn::sanitize_date (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: minuit du même jour
RETURN fn::sanitize_date(d"2026-08-03T12:34:56.789Z") == d"2026-08-03T00:00:00Z";

-- test: entrée absente → NONE
RETURN fn::sanitize_date(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_date(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_date("2026-08-03");
