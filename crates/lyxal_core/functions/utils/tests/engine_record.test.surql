-- lyxal-test: assertions
-- Tests de fn::utils_engine_record (format : crates/lyxal_core/implementation_plan.md §5).

-- test: enregistrement sans arrêt
RETURN fn::utils_engine_record(fn::utils_engine_state(1, "x", NONE), "detect", "finding", { score: 5 }) == object::extend(fn::utils_engine_state(1, "x", NONE), { records: [{ path: "x", rule: "detect", kind: "finding", data: { score: 5 } }] });

-- test: genre vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_record(fn::utils_engine_state(1, "", NONE), "r", " ", 1);
