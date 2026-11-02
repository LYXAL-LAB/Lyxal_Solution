-- lyxal-test: assertions
-- Tests de fn::utils_number_median (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: impair
RETURN fn::utils_number_median([3, 1, 2]) == 2;

-- test: pair
RETURN fn::utils_number_median([4, 1, 3, 2]) == 2.5f;

-- test: pair de deux entiers
RETURN fn::utils_number_median([1, 2]) == 1.5f;

-- test: vide
RETURN fn::utils_number_median([]) == NONE;
