-- lyxal-test: assertions
-- Tests de fn::utils_array_group_by (format : crates/lyxal_core/implementation_plan.md §5).

-- test: groupes par clé
RETURN fn::utils_array_group_by([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], "team") == { x: [{ name: "A", team: "x", age: 30 }, { name: "C", team: "x", age: 25 }], y: [{ name: "B", team: "y", age: 20 }] };
