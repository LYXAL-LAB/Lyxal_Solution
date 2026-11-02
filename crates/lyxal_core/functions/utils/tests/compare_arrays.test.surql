-- lyxal-test: assertions
-- Tests de fn::utils_compare_arrays (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: ordre ignoré
RETURN fn::utils_compare_arrays([1, 2], [2, 1], true) == { equal: true, left_only: [], right_only: [] };

-- test: différences
RETURN fn::utils_compare_arrays([1, 2], [2, 3], false) == { equal: false, left_only: [1], right_only: [3] };
