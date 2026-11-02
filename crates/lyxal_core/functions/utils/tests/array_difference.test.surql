-- lyxal-test: assertions
-- Tests de fn::utils_array_difference (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: éléments absents de droite
RETURN fn::utils_array_difference([1, 2, 3, 2], [2]) == [1, 3];
