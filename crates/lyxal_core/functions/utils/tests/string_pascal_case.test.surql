-- lyxal-test: assertions
-- Tests de fn::utils_string_pascal_case (format : crates/lyxal_core/implementation_plan.md §5).

-- test: séparateurs
RETURN fn::utils_string_pascal_case("hello big world") == "HelloBigWorld";

-- test: depuis camelCase
RETURN fn::utils_string_pascal_case("helloWorld") == "HelloWorld";

-- test: chaîne vide
RETURN fn::utils_string_pascal_case("") == "";
