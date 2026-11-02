-- lyxal-test: assertions
-- Tests de fn::utils_engine_debug_summary (format : crates/lyxal_core/implementation_plan.md §5).

-- test: résumé
RETURN fn::utils_engine_debug_summary([fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z"), fn::utils_engine_trace("age", "min", 1, 1, false, { code: "CORE_VALIDATION_TOO_SMALL" }, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.005Z")]) == { trace_count: 2, failed_count: 1, total_duration: 7ms, by_rule: { trim: { count: 1, failed: 0, total_duration: 2ms }, min: { count: 1, failed: 1, total_duration: 5ms } } };

-- test: aucune trace
RETURN fn::utils_engine_debug_summary([]) == { trace_count: 0, failed_count: 0, total_duration: 0ns, by_rule: {} };
