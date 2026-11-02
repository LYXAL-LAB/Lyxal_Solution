-- lyxal-test: assertions
-- Tests de fn::utils_engine_step (format : crates/lyxal_core/implementation_plan.md §5).

-- test: règle normalisée
RETURN fn::utils_engine_step(" Trim ", NONE, NONE) == { rule: "trim", value: NONE, options: {} };

-- test: valeur et options
RETURN fn::utils_engine_step("min", 3, { strict: true }) == { rule: "min", value: 3, options: { strict: true } };

-- test: règle vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_step(" ", 1, NONE);
