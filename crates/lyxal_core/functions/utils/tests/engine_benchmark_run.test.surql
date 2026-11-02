-- lyxal-test: assertions
-- Tests de fn::utils_engine_benchmark_run (format : crates/lyxal_core/implementation_plan.md §5).

-- test: campagne
RETURN fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z").sample_count == 4 AND fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z").wall_duration == 2s;

-- test: fin avant début
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_benchmark_run("a", [], d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z");
