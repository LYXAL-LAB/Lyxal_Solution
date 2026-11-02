-- lyxal-test: assertions
-- Tests de fn::validation_step_apply (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur valide normalisée
RETURN fn::validation_step_apply(fn::utils_engine_state(" A@Example.com ", "f", NONE), { rule: "email", options: { max_length: 254 } }).value == "A@Example.com";

-- test: valeur invalide : erreur et arrêt
RETURN fn::validation_step_apply(fn::utils_engine_state("x", "f", NONE), { rule: "email", options: { max_length: 254 } }).issues == [{ path: "f", rule: "email", code: "CORE_VALIDATION_FORMAT", details: { expected: "email" } }];

-- test: arrêt positionné
RETURN fn::validation_step_apply(fn::utils_engine_state("x", "f", NONE), { rule: "email", options: { max_length: 254 } }).stop;

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_step_apply(fn::utils_engine_state(1, "", NONE), { rule: "inconnue", options: {} });
