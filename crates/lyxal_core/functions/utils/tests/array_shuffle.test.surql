-- lyxal-test: assertions
-- Tests de fn::utils_array_shuffle (format : crates/lyxal_core/implementation_plan.md §5).

-- test: mêmes éléments
RETURN array::sort::asc(fn::utils_array_shuffle([3, 1, 2])) == [1, 2, 3];
