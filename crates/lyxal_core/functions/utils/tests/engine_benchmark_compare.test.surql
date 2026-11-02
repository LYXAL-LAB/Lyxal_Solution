-- lyxal-test: assertions
-- Tests de fn::utils_engine_benchmark_compare (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: régression détectée
RETURN fn::utils_engine_benchmark_compare({ average: 10ms, p95: 20ms }, { average: 15ms, p95: 21ms }, 0.2).regression;

-- test: dans la tolérance
RETURN fn::utils_engine_benchmark_compare({ average: 10ms, p95: 20ms }, { average: 11ms, p95: 21ms }, 0.2) == { average_ratio: 1.1f, p95_ratio: 1.05f, regression: false };

-- test: référence vide
RETURN fn::utils_engine_benchmark_compare({ average: NONE, p95: NONE }, { average: 1ms, p95: 1ms }, 0.1).regression == false;

-- test: tolérance négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_benchmark_compare({}, {}, -1);
