-- lyxal-test: assertions
-- Tests de fn::utils_cache_size (format : crates/lyxal_core/implementation_plan.md §5).

-- test: taille JSON
RETURN fn::utils_cache_size([{ a: 1 }]) == { entry_count: 1, estimated_bytes: 9, measurement: "json_character_length" };
