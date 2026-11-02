-- lyxal-test: assertions
-- Tests de fn::utils_collection_frequency (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fréquences
RETURN fn::utils_collection_frequency(["a", "b", "a"]) == { a: 2, b: 1 };
