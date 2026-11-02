-- lyxal-test: assertions
-- Tests de fn::utils_collection_count_by (format : crates/lyxal_core/implementation_plan.md §5).

-- test: comptage par clé
RETURN fn::utils_collection_count_by([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], "team") == { x: 2, y: 1 };
