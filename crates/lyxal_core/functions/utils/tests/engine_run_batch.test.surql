-- lyxal-test: assertions
-- Tests de fn::utils_engine_run_batch (format : crates/lyxal_core/implementation_plan.md §5).

-- test: un état par valeur
RETURN fn::utils_engine_run_batch([" ab ", "c"], fn::utils_engine_pipeline([{ rule: "trim" }, { rule: "min", value: 2 }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).map(|$s| array::len($s.issues)) == [0, 1];
