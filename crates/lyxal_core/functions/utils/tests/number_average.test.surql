-- lyxal-test: assertions
-- Tests de fn::utils_number_average (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: moyenne
RETURN fn::utils_number_average([2, 4]) == 3;

-- test: vide
RETURN fn::utils_number_average([]) == NONE;
