-- lyxal-test: assertions
-- Tests de fn::utils_cache_size (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: taille JSON
RETURN fn::utils_cache_size([{ a: 1 }]) == { entry_count: 1, estimated_bytes: 9, measurement: "json_character_length" };
