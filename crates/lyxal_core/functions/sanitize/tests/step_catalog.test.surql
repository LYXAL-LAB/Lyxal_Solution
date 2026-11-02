-- lyxal-test: assertions
-- Tests de fn::sanitize_step_catalog (format : crates/lyxal_core/implementation_plan.md §5).

-- test: une règle par fonction de valeurs (sauf date_range), plus default
RETURN array::len(fn::sanitize_step_catalog()) == 93;

-- test: règles uniques
RETURN array::len(array::distinct(fn::sanitize_step_catalog().map(|$e| $e.rule))) == 93;

-- test: sanitize_object exposée sous object_or_empty
RETURN fn::sanitize_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: "object_or_empty", options: {} }).value == {};

-- test: options obligatoires déclarées
RETURN array::find(fn::sanitize_step_catalog(), |$e| $e.rule = "clamp").required == ["min", "max"];

-- test: règles idempotentes : liste fermée
RETURN fn::sanitize_step_catalog().filter(|$e| $e.idempotent = true).map(|$e| $e.rule) == ["collapse_whitespace", "lowercase", "trim", "trim_left", "trim_right", "uppercase", "default"];

-- test: règles idempotentes : double application = simple application
RETURN array::all(fn::sanitize_step_catalog().filter(|$e| $e.idempotent = true AND $e.required IS NONE).map(|$e| $e.rule), |$rule| array::all(["  A  b\t c ", "x\n\ny", "", "ÉtÉ  "], |$input| fn::sanitize_pipeline_execute($input, [{ rule: $rule }, { rule: $rule }], 10) == fn::sanitize_pipeline_execute($input, [{ rule: $rule }], 10)));

-- test: optimisation sans effet sur le résultat
RETURN fn::sanitize_pipeline_execute(" A  B ", fn::utils_engine_optimize([{ rule: "trim" }, { rule: "trim" }, { rule: "lowercase" }, { rule: "credit_card_mask" }, { rule: "credit_card_mask" }], fn::sanitize_step_catalog()).pipeline, 10) == fn::sanitize_pipeline_execute(" A  B ", [{ rule: "trim" }, { rule: "trim" }, { rule: "lowercase" }, { rule: "credit_card_mask" }, { rule: "credit_card_mask" }], 10);

-- test: aucune règle du moteur masquée
RETURN array::len(fn::utils_engine_pipeline([], fn::sanitize_step_catalog(), 1)) == 0;

-- test: chaque règle est appliquée par l'aiguillage
RETURN array::all(fn::sanitize_step_catalog().filter(|$e| $e.required IS NONE).map(|$e| $e.rule), |$rule| fn::sanitize_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: $rule, options: {} }).stop == false);
