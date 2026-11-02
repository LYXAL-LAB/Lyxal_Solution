-- lyxal-test: assertions
-- Tests de fn::utils_engine_debug_add (format : crates/lyxal_core/implementation_plan.md §5).

-- test: trace ajoutée
RETURN array::len(fn::utils_engine_debug_add(fn::utils_engine_debug_session("s", d"2026-01-01T00:00:00Z"), fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z")).traces) == 1;
