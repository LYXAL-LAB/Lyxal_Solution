-- lyxal-test: assertions
-- Tests de fn::utils_engine_pipeline_merge (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: concaténation
RETURN fn::utils_engine_pipeline_merge([{ rule: "a" }], [{ rule: "b" }], 2) == [{ rule: "a" }, { rule: "b" }];

-- test: borne dépassée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline_merge([{ rule: "a" }], [{ rule: "b" }], 1);
