-- lyxal-test: assertions
-- Tests de fn::sanitize_rfc3339 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: sans fraction
RETURN fn::sanitize_rfc3339(d"2026-01-01T10:00:00Z") == "2026-01-01T10:00:00Z";

-- test: avec fraction
RETURN fn::sanitize_rfc3339(d"2026-01-01T10:00:00.5Z") == "2026-01-01T10:00:00.500Z";

-- test: entrée absente → NONE
RETURN fn::sanitize_rfc3339(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_rfc3339(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_rfc3339("2026");
