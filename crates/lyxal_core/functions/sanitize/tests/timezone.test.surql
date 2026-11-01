-- lyxal-test: assertions
-- Tests de fn::sanitize_timezone (format : crates/lyxal_core/implementation_plan.md §5).

-- test: Z
RETURN fn::sanitize_timezone(" z ") == "+00:00";

-- test: UTC
RETURN fn::sanitize_timezone("utc") == "+00:00";

-- test: fuseau nommé conservé
RETURN fn::sanitize_timezone(" Europe/Zurich ") == "Europe/Zurich";

-- test: entrée absente → NONE
RETURN fn::sanitize_timezone(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_timezone(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_timezone(42);
