-- lyxal-test: assertions
-- Tests de fn::utils_engine_run_step (format : crates/lyxal_core/implementation_plan.md §5).

-- test: each : chemins indexés
RETURN fn::utils_engine_run(fn::utils_engine_state([" ab ", "c"], "", NONE), fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [{ rule: "trim" }, { rule: "min", value: 2 }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues.map(|$i| $i.path) == ["[1]"];

-- test: each : valeurs nettoyées
RETURN fn::utils_engine_run(fn::utils_engine_state([" ab ", " cd"], "", NONE), fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [{ rule: "trim" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == ["ab", "cd"];

-- test: each : NONE traversé
RETURN fn::utils_engine_run(fn::utils_engine_state(NONE, "", NONE), fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value IS NONE;

-- test: when : branche then
RETURN fn::utils_engine_run(fn::utils_engine_state(" a ", "", NONE), fn::utils_engine_pipeline([{ rule: "when", options: { equals: " a ", then: [{ rule: "trim" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == "a";

-- test: when : branche else
RETURN fn::utils_engine_run(fn::utils_engine_state(" b ", "", NONE), fn::utils_engine_pipeline([{ rule: "when", options: { in: [" a "], then: [{ rule: "trim" }], else: [{ rule: "min", value: 9 }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues[0].code == "CORE_VALIDATION_TOO_SHORT";

-- test: when : champ voisin
RETURN fn::utils_engine_run(fn::utils_engine_state(" x ", "siret", { type: "pro" }), fn::utils_engine_pipeline([{ rule: "when", options: { field: "type", equals: "pro", then: [{ rule: "trim" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == "x";

-- test: one_of : première branche sans erreur
RETURN fn::utils_engine_run(fn::utils_engine_state("abc", "", NONE), fn::utils_engine_pipeline([{ rule: "one_of", options: { pipelines: [[{ rule: "min", value: 5 }], [{ rule: "min", value: 2 }]] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues == [];

-- test: one_of : branches suivantes non exécutées
RETURN fn::utils_engine_run(fn::utils_engine_state("abc", "", NONE), fn::utils_engine_pipeline([{ rule: "one_of", options: { pipelines: [[], [{ rule: "each", options: { pipeline: [] } }]] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues == [];

-- test: one_of : aucune branche
RETURN fn::utils_engine_run(fn::utils_engine_state("a", "", NONE), fn::utils_engine_pipeline([{ rule: "one_of", options: { pipelines: [[{ rule: "min", value: 5 }], [{ rule: "min", value: 2 }]] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).issues[0].code == "CORE_VALIDATION_COMBINATION";

-- test: object : schéma imbriqué
RETURN fn::utils_engine_run(fn::utils_engine_state({ contact: { name: " Al " } }, "", NONE), fn::utils_engine_pipeline([{ rule: "object", options: { schema: { fields: { contact: { pipeline: [{ rule: "object", options: { schema: { fields: { name: { pipeline: [{ rule: "trim" }] } } } } }] } } } } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s }).value == { contact: { name: "Al" } };

-- test: each sur une valeur qui n'est pas un tableau
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_run(fn::utils_engine_state("a", "", NONE), fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10), |$s, $step| IF $step.rule = "trim" { object::extend($s, { value: string::trim($s.value) }) } ELSE IF string::len($s.value) < $step.value { fn::utils_engine_issue($s, "min", "CORE_VALIDATION_TOO_SHORT", { min: $step.value }) } ELSE { $s });
