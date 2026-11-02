-- lyxal-test: assertions
-- Tests de fn::utils_object_has_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chemin existant
RETURN fn::utils_object_has_path({ a: { b: 1 } }, ["a", "b"]);

-- test: chemin absent
RETURN !fn::utils_object_has_path({ a: 1 }, ["a", "b"]);

-- test: chemin vide
RETURN fn::utils_object_has_path({}, []);
