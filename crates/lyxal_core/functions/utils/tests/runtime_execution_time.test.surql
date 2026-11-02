-- lyxal-test: assertions
-- Tests de fn::utils_runtime_execution_time (format : crates/lyxal_core/implementation_plan.md §5).

-- test: durée
RETURN fn::utils_runtime_execution_time(d"2026-01-01T11:00:00Z", d"2026-01-01T12:00:00Z") == 1h;

-- test: fin avant début
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_runtime_execution_time(d"2026-01-01T12:00:00Z", d"2026-01-01T11:00:00Z");
