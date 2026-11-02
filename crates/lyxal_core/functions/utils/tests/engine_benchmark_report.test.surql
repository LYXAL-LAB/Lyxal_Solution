-- lyxal-test: assertions
-- Tests de fn::utils_engine_benchmark_report (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: rapport sans référence
RETURN fn::utils_engine_benchmark_report(fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z"), NONE, 0.1).comparison IS NONE AND fn::utils_engine_benchmark_report(fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z"), NONE, 0.1).stats.sample_count == 4;

-- test: rapport avec référence
RETURN fn::utils_engine_benchmark_report(fn::utils_engine_benchmark_run("email", [fn::utils_engine_benchmark_sample("a", 10ms, true, NONE), fn::utils_engine_benchmark_sample("a", 30ms, true, NONE), fn::utils_engine_benchmark_sample("a", 20ms, false, NONE), fn::utils_engine_benchmark_sample("a", 40ms, true, NONE)], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:02Z"), { average: 10ms, p95: 10ms }, 0.1).comparison.regression;
