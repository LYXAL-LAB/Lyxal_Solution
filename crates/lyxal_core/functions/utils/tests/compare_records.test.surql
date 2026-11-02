-- lyxal-test: assertions
-- Tests de fn::utils_compare_records (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: champs modifiés
RETURN fn::utils_compare_records({ a: 1, b: 2 }, { a: 1, b: 3 }, ["a", "b"]) == { equal: false, changes: [{ key: "b", left: 2, right: 3, changed: true }], change_count: 1 };
