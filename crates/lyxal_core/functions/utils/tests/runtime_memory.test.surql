-- lyxal-test: assertions
-- Tests de fn::utils_runtime_memory (format : crates/lyxal_core/implementation_plan.md §5).

-- test: taille JSON
RETURN fn::utils_runtime_memory([1, 2]) == { estimated_bytes: 5, measurement: "json_character_length", value_type: "array" };
