-- lyxal-test: assertions
-- Tests de fn::utils_string_camel_case (format : crates/lyxal_core/implementation_plan.md §5).

-- test: séparateurs
RETURN fn::utils_string_camel_case(" hello_big-world ") == "helloBigWorld";

-- test: déjà en camelCase
RETURN fn::utils_string_camel_case("helloWorld") == "helloWorld";

-- test: chaîne vide
RETURN fn::utils_string_camel_case("  ") == "";
