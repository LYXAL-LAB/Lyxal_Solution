-- lyxal-test: assertions
-- Tests de fn::utils_engine_pipeline_info (format : crates/lyxal_core/implementation_plan.md §5).

-- test: étapes, règles et coût
RETURN fn::utils_engine_pipeline_info(fn::utils_engine_pipeline([{ rule: "trim" }, { rule: "min", value: 1 }, { rule: "trim" }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }]) == { step_count: 3, rules: ["trim", "min"], cost: 5 };

-- test: règle du moteur au coût 1
RETURN fn::utils_engine_pipeline_info(fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }]).cost == 1;
