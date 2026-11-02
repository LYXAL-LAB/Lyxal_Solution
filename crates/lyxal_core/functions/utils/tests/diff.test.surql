-- lyxal-test: assertions
-- Tests de fn::utils_diff (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeurs différentes
RETURN fn::utils_diff(1, "1") == { equal: false, left: 1, right: "1", left_type: "int", right_type: "string" };

-- test: égalité profonde
RETURN fn::utils_diff({ a: [1, { b: 2 }] }, { a: [1, { b: 2 }] }).equal;
