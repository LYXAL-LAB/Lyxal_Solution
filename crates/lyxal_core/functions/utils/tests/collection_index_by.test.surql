-- lyxal-test: assertions
-- Tests de fn::utils_collection_index_by (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: index par clé
RETURN fn::utils_collection_index_by([{ id: "a", v: 1 }, { id: "b", v: 2 }], "id") == { a: { id: "a", v: 1 }, b: { id: "b", v: 2 } };
