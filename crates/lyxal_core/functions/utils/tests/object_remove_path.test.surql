-- lyxal-test: assertions
-- Tests de fn::utils_object_remove_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clé imbriquée retirée
RETURN fn::utils_object_remove_path({ a: { b: 1, c: 2 } }, ["a", "b"]) == { a: { c: 2 } };

-- test: chemin absent
RETURN fn::utils_object_remove_path({ a: 1 }, ["x", "y"]) == { a: 1 };
