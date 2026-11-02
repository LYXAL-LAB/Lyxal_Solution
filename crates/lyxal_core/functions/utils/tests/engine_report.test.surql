-- lyxal-test: assertions
-- Tests de fn::utils_engine_report (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rapport valide
RETURN fn::utils_engine_report(fn::utils_engine_run(fn::utils_engine_state(" ab ", "", NONE), fn::utils_engine_pipeline([{ rule: "trim" }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s })) == { valid: true, value: "ab", errors: [], warnings: [], by_field: {} };

-- test: erreurs par champ
RETURN fn::utils_engine_report(fn::utils_engine_run_object(fn::utils_engine_state({ extra: 1 }, "", NONE), fn::utils_engine_schema({ name: "contact", fields: { name: { pipeline: [{ rule: "trim" }, { rule: "min", value: 2 }], required: true }, note: { pipeline: [{ rule: "trim" }], nullable: true }, lang: { default: "fr" } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s })).by_field == { name: ["CORE_VALIDATION_REQUIRED"], extra: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: racine notée $
RETURN fn::utils_engine_report(fn::utils_engine_run(fn::utils_engine_state("a", "", NONE), fn::utils_engine_pipeline([{ rule: "min", value: 2 }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s })).by_field == { "$": ["CORE_VALIDATION_TOO_SHORT"] };
