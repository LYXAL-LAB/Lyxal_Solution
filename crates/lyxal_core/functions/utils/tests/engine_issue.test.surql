-- lyxal-test: assertions
-- Tests de fn::utils_engine_issue (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: erreur ajoutée et arrêt
RETURN fn::utils_engine_issue(fn::utils_engine_state(1, "x", NONE), "min", "CORE_VALIDATION_TOO_SMALL", NONE) == object::extend(fn::utils_engine_state(1, "x", NONE), { issues: [{ path: "x", rule: "min", code: "CORE_VALIDATION_TOO_SMALL", details: {} }], stop: true });

-- test: code vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_issue(fn::utils_engine_state(1, "", NONE), "min", "", NONE);
