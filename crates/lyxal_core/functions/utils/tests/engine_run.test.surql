-- lyxal-test: assertions
-- Tests de fn::utils_engine_run (format : crates/lyxal_core/implementation_plan.md §5).

-- test: étapes du domaine
RETURN fn::utils_engine_run(fn::utils_engine_state("  abc  ", "", NONE), fn::utils_engine_pipeline([{ rule: "trim" }, { rule: "min", value: 2 }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == "abc";

-- test: erreur et arrêt
RETURN fn::utils_engine_run(fn::utils_engine_state(" a ", "", NONE), fn::utils_engine_pipeline([{ rule: "trim" }, { rule: "min", value: 2 }, { rule: "min", value: 5 }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues == [{ path: "", rule: "min", code: "CORE_VALIDATION_TOO_SHORT", details: { min: 2 } }];

-- test: pipeline vide
RETURN fn::utils_engine_run(fn::utils_engine_state(1, "", NONE), fn::utils_engine_pipeline([], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == 1;
