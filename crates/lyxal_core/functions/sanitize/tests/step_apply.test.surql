-- lyxal-test: assertions
-- Tests de fn::sanitize_step_apply (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: règle sans option
RETURN fn::sanitize_step_apply(fn::utils_engine_state(" A  b ", "", NONE), { rule: "trim", options: {} }).value == "A  b";

-- test: option par défaut
RETURN fn::sanitize_step_apply(fn::utils_engine_state(" A  b ", "", NONE), { rule: "slug", options: {} }).value == "a-b";

-- test: option transmise
RETURN fn::sanitize_step_apply(fn::utils_engine_state(" A  b ", "", NONE), { rule: "slug", options: { separator: "_" } }).value == "a_b";

-- test: option booléenne false conservée
RETURN fn::sanitize_step_apply(fn::utils_engine_state("a  b", "", NONE), { rule: "normalize_unicode", options: { collapse_whitespace: false } }).value == "a  b";

-- test: default remplace NONE
RETURN fn::sanitize_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: "default", options: { value: 5 } }).value == 5;

-- test: default conserve NULL
RETURN fn::sanitize_step_apply(fn::utils_engine_state(NULL, "", NONE), { rule: "default", options: { value: 5 } }).value == NULL;

-- test: default conserve une valeur
RETURN fn::sanitize_step_apply(fn::utils_engine_state(1, "", NONE), { rule: "default", options: { value: 5 } }).value == 1;

-- test: valeur NONE traversée
RETURN fn::sanitize_step_apply(fn::utils_engine_state(NONE, "", NONE), { rule: "email", options: {} }).value IS NONE;

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_step_apply(fn::utils_engine_state("a", "", NONE), { rule: "inconnue", options: {} });
