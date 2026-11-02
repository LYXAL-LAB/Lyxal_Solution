-- lyxal-test: assertions
-- Tests de fn::utils_array_difference (format : crates/lyxal_core/implementation_plan.md §5).

-- test: éléments absents de droite
RETURN fn::utils_array_difference([1, 2, 3, 2], [2]) == [1, 3];
