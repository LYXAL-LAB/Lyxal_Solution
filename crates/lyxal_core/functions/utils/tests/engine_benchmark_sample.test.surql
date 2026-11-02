-- lyxal-test: assertions
-- Tests de fn::utils_engine_benchmark_sample (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: échantillon
RETURN fn::utils_engine_benchmark_sample(" A ", 5ms, true, NONE) == { name: "a", duration: 5ms, ok: true, metadata: {} };

-- test: nom vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_benchmark_sample("", 5ms, true, NONE);
