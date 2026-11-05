-- lyxal-test: assertions
-- Tests de fn::validation_step_catalog (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: une règle par validateur à une seule valeur
RETURN array::len(fn::validation_step_catalog()) == 176;

-- test: règles uniques
RETURN array::len(array::distinct(fn::validation_step_catalog().map(|$e| $e.rule))) == 176;

-- test: paramètres non optionnels obligatoires
RETURN array::find(fn::validation_step_catalog(), |$e| $e.rule = "min_length").required == ["min_length"];

-- test: paramètres optionnels facultatifs
RETURN array::find(fn::validation_step_catalog(), |$e| $e.rule = "integer").required IS NONE;

-- test: validation_object exposée sous is_object
RETURN array::any(fn::validation_step_catalog(), |$e| $e.rule = "is_object");

-- test: aucune règle déclarée idempotente
RETURN !array::any(fn::validation_step_catalog(), |$e| $e.idempotent = true);

-- test: aucune règle du moteur masquée
RETURN array::len(fn::utils_engine_pipeline([], fn::validation_step_catalog(), 1)) == 0;

-- test: validateurs à plusieurs valeurs absents
RETURN !array::any(fn::validation_step_catalog(), |$e| $e.rule IN ["compare", "date_range", "time_range", "coordinates"]);

-- test: chaque règle sans option obligatoire est appliquée par l'aiguillage
RETURN array::all(fn::validation_step_catalog().filter(|$e| $e.required IS NONE).map(|$e| $e.rule), |$rule| type::is_object(fn::validation_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: $rule, options: {} })));
