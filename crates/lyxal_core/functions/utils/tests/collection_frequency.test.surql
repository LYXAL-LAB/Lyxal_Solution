-- lyxal-test: assertions
-- Tests de fn::utils_collection_frequency (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: fréquences
RETURN fn::utils_collection_frequency(["a", "b", "a"]) == { a: 2, b: 1 };
