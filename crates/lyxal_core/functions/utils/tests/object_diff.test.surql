-- lyxal-test: assertions
-- Tests de fn::utils_object_diff (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: changements
RETURN fn::utils_object_diff({ a: 1, b: 2 }, { a: 1, c: 3 }) == { changed: true, changes: [{ key: "b", left: 2, right: NONE, changed: true }, { key: "c", left: NONE, right: 3, changed: true }], change_count: 2 };
