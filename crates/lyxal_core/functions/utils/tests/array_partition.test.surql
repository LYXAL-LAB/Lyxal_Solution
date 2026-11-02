-- lyxal-test: assertions
-- Tests de fn::utils_array_partition (format : crates/lyxal_core/implementation_plan.md §5).

-- test: deux partitions
RETURN fn::utils_array_partition([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], "team", "y") == { matched: [{ name: "B", team: "y", age: 20 }], unmatched: [{ name: "A", team: "x", age: 30 }, { name: "C", team: "x", age: 25 }] };
