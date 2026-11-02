-- lyxal-test: assertions
-- Tests de fn::utils_object_merge_deep (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fusion profonde
RETURN fn::utils_object_merge_deep({ a: { x: 1, y: 2 }, b: 1 }, { a: { y: 3 }, c: 4 }) == { a: { x: 1, y: 3 }, b: 1, c: 4 };
