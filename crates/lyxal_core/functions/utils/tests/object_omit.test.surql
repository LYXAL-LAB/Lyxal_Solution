-- lyxal-test: assertions
-- Tests de fn::utils_object_omit (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: clés retirées
RETURN fn::utils_object_omit({ a: 1, b: 2, c: 3 }, ["b"]) == { a: 1, c: 3 };
