-- lyxal-test: assertions
-- Tests de fn::utils_engine_warning (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: avertissement sans arrêt
RETURN fn::utils_engine_warning(fn::utils_engine_state(1, "", NONE), "r", "CORE_X", { a: 1 }) == object::extend(fn::utils_engine_state(1, "", NONE), { warnings: [{ path: "", rule: "r", code: "CORE_X", details: { a: 1 } }] });

-- test: code vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_warning(fn::utils_engine_state(1, "", NONE), "r", " ", NONE);
