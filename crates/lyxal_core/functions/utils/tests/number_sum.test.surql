-- lyxal-test: assertions
-- Tests de fn::utils_number_sum (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: somme
RETURN fn::utils_number_sum([1, 2, 3.5f]) == 6.5f;

-- test: vide
RETURN fn::utils_number_sum([]) == 0;
