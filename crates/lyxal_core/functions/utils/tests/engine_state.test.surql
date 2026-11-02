-- lyxal-test: assertions
-- Tests de fn::utils_engine_state (format : crates/lyxal_core/implementation_plan.md §5).

-- test: état initial
RETURN fn::utils_engine_state("a", " x ", { x: "a" }) == { value: "a", issues: [], warnings: [], records: [], stop: false, path: "x", parent: { x: "a" } };
