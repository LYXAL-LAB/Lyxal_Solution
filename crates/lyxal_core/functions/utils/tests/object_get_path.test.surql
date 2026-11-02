-- lyxal-test: assertions
-- Tests de fn::utils_object_get_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chemin existant
RETURN fn::utils_object_get_path({ a: { b: { c: 1 } } }, ["a", "b", "c"], 0) == 1;

-- test: chemin absent
RETURN fn::utils_object_get_path({ a: { b: 1 } }, ["a", "x", "y"], "défaut") == "défaut";
