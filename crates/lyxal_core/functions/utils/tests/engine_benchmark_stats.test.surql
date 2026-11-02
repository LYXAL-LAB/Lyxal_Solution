-- lyxal-test: assertions
-- Tests de fn::utils_engine_benchmark_stats (format : crates/lyxal_core/implementation_plan.md §5).

-- test: statistiques
RETURN fn::utils_engine_benchmark_stats(fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z")) == { sample_count: 4, success_rate: 0.75f, min: 10ms, max: 40ms, average: 25ms, p50: 20ms, p95: 30ms, p99: 30ms, throughput: 2f };

-- test: campagne vide
RETURN fn::utils_engine_benchmark_stats(fn::utils_engine_benchmark_run("a", [], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z")).average IS NONE;
