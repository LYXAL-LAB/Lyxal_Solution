-- lyxal-test: assertions
-- Tests de fn::utils_array_intersect (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: éléments communs sans doublon
RETURN fn::utils_array_intersect([1, 2, 2, 3], [2, 3, 4]) == [2, 3];
