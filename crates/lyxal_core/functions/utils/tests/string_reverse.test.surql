-- lyxal-test: assertions
-- Tests de fn::utils_string_reverse (format : crates/lyxal_core/implementation_plan.md §5).

-- test: inversion
RETURN fn::utils_string_reverse("abc") == "cba";

-- test: accents
RETURN fn::utils_string_reverse("été") == "été";
