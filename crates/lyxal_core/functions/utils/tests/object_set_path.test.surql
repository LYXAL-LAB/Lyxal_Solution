-- lyxal-test: assertions
-- Tests de fn::utils_object_set_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: création des niveaux
RETURN fn::utils_object_set_path({ a: 1 }, ["b", "c"], 2) == { a: 1, b: { c: 2 } };

-- test: chemin vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_object_set_path({}, [], 1);
