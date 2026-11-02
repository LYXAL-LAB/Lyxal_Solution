-- lyxal-test: assertions
-- Tests de fn::utils_compare_strings (format : crates/lyxal_core/implementation_plan.md §5).

-- test: insensible à la casse
RETURN fn::utils_compare_strings(" Abc ", "abc", false, true) == 0;

-- test: ordre
RETURN fn::utils_compare_strings("a", "b", true, false) == -1;
