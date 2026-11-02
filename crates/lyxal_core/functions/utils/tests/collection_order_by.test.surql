-- lyxal-test: assertions
-- Tests de fn::utils_collection_order_by (format : crates/lyxal_core/implementation_plan.md §5).

-- test: plusieurs critères
RETURN fn::utils_collection_order_by([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], [{ key: "team" }, { key: "age", direction: "desc" }]).map(|$p| $p.name) == ["A", "C", "B"];
